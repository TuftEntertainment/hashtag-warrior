#!/usr/bin/python
# ----------------------------------------------------------------------------
# Generates JavaScript Bindings glue code after C / Objective-C code
#
# Author: Ricardo Quesada
# Copyright 2012 (C) Zynga, Inc
#
# License: MIT
# ----------------------------------------------------------------------------
'''
Generates JavaScript Bindings glue code after C / Objective-C code
'''

__docformat__ = 'restructuredtext'


# python
import sys
import os
import re
import getopt
import ast
import xml.etree.ElementTree as ET
import itertools
import copy
import datetime
import ConfigParser
import string


class MethodNotFoundException(Exception):
    pass


class ParseException(Exception):
    pass


class ParseOKException(Exception):
    pass


#
# Globals
#
BINDINGS_PREFIX = 'jsb_'
PROXY_PREFIX = 'JSB_'
METHOD_CONSTRUCTOR, METHOD_CLASS, METHOD_INIT, METHOD_REGULAR = xrange(4)
JSB_VERSION = 'v0.6'


# get_class from: http://stackoverflow.com/a/452981
def get_class(kls):
    parts = kls.split('.')
    module = ".".join(parts[:-1])
    if len(parts) == 1:
        m = sys.modules[__name__]
        m = getattr(m, parts[0])
    else:
        m = __import__(module)
        for comp in parts[1:]:
            m = getattr(m, comp)
    return m

# uncapitalize from: http://stackoverflow.com/a/3847369
uncapitalize = lambda s: s[:1].lower() + s[1:] if s else ''


# xml2d recipe copied from here:
# http://code.activestate.com/recipes/577722-xml-to-python-dictionary-and-back/
def xml2d(e):
    """Convert an etree into a dict structure

    @type  e: etree.Element
    @param e: the root of the tree
    @return: The dictionary representation of the XML tree
    """
    def _xml2d(e):
        kids = dict(e.attrib)
        for k, g in itertools.groupby(e, lambda x: x.tag):
            g = [_xml2d(x) for x in g]
            kids[k] = g
        return kids
    return {e.tag: _xml2d(e)}


class JSBGenerate(object):

    def __init__(self, config):

        self.config = config

        # Generating Object Oriented Functions ?
        self.generating_OOF = False

        # list of JS functions names that have a C / C++ implementation
        # Used to generate 'externs' definitions for Google Closure
        self.bound_js_functions = []

        #
        # UGLY CODE XXX
        # This should be accessed using self.config, not the following ugly code
        #
        self.namespace = config.namespace
        self.bs = config.bs

        # functions
        self.struct_properties = config.struct_properties
        self.import_files = config.import_files
        self.compatible_with_cpp = config.compatible_with_cpp
        self.functions_to_bind = config.functions_to_bind
        self.callback_functions = config.callback_functions
        self.struct_opaque = config.struct_opaque
        self.struct_manual = config.struct_manual
        self.function_properties = config.function_properties
        self.function_prefix = config.function_prefix
        self.function_classes = config.function_classes

        # OO Functions
        self.c_object_properties = config.c_object_properties
        self.manual_bound_methods = config.manual_bound_methods

        # classes
        self.supported_classes = config.supported_classes
        self.class_properties = config.class_properties
        self.classes_to_bind = config.classes_to_bind
        self.classes_to_ignore = config.classes_to_ignore
        self.method_properties = config.method_properties
        self.class_properties = config.class_properties
        self.complement = config.complement
        self.class_manual = config.class_manual
        self.parsed_classes = config.parsed_classes
        self._inherit_class_methods = config._inherit_class_methods
        self.callback_methods = config.callback_methods
        self.manual_methods = config.manual_methods
        self.class_prefix = config.class_prefix

        # constants
        self.constant_properties = config.constant_properties

        # JS
        self.js_new_methods = config.js_new_methods

        # Misc
        self.bridgesupport_files = config.bridgesupport_files

        #
        # conversion rules
        #
        self.init_args_conversion()

    def init_args_conversion(self):
        #
        # Conversion rules
        #

        # Shared
        # Left column: BridgeSupport types
        # Right column: JS types
        self.supported_declared_types = {
            'NSString*': 'S',
            'NSArray*': 'array',
            'NSMutableArray*': 'array',
            'CCArray*': 'array',
            'NSSet*': 'set',
            'NSDictionary*': 'dict',
            'NSMutableDictionary*': 'dict',
            'const char*': 'char*',
            'const unsigned char*': 'char*',
            'char*': 'char*',
            'unsigned char*': 'char*',
            'void (^)(id)': 'f',
            'void (^)(CCNode *)': 'f',
        }

        self.supported_types = {
            'f': 'd',  # float
            'd': 'd',  # double
            'i': 'i',  # integer
            'I': 'u',  # unsigned integer
            'c': 'c',  # char
            'C': 'c',  # unsigned char
            'B': 'b',  # BOOL
            's': 'c',  # short
            'v':  None,  # void (for retval)
            'L': 'long',          # long (special conversion)
            'Q': 'longlong',      # long long (special conversion)
        }

        self.objc_to_js_conversions = {
            'i': 'INT_TO_JSVAL((int32_t)%(objc_val)s)',
            'u': 'UINT_TO_JSVAL((uint32_t)%(objc_val)s)',
            'b': 'BOOLEAN_TO_JSVAL(%(objc_val)s)',
            's': 'STRING_TO_JSVAL(%(objc_val)s)',
            'd': 'DOUBLE_TO_JSVAL(%(objc_val)s)',
            'c': 'INT_TO_JSVAL((int32_t)%(objc_val)s)',
            'long': 'JSB_jsval_from_long(cx, %(objc_val)s)',                # long: not supported on JS 64-bit
            'longlong': 'JSB_jsval_from_longlong(cx, %(objc_val)s)',        # long long: not supported on JS
            'void': 'JSVAL_VOID',
            None: 'JSVAL_VOID',
            'o': 'JSB_jsval_from_NSObject(cx, %(objc_val)s)',
            'S': 'JSB_jsval_from_NSString( cx, (NSString*) %(objc_val)s )',
            'char*': 'JSB_jsval_from_charptr( cx, %(objc_val)s )',
            'array': 'JSB_jsval_from_NSArray( cx, (NSArray*) %(objc_val)s )',
            'set': 'JSB_jsval_from_NSSet( cx, (NSSet*) %(objc_val)s )',
            'dict': 'JSB_jsval_from_NSDictionary( cx, (NSDictionary*) %(objc_val)s )',
        }

        # Arguments only
        # b      JSBool          Boolean
        # c      uint16_t/jschar ECMA uint16_t, Unicode char
        # i      int32_t         ECMA int32_t
        # u      uint32_t        ECMA uint32_t
        # j      int32_t         Rounded int32_t (coordinate)
        # d      double          IEEE double
        # I      double          Integral IEEE double
        # S      JSString *      Unicode string, accessed by a JSString pointer
        # W      jschar *        Unicode character vector, 0-terminated (W for wide)
        # o      JSObject *      Object reference
        # f      JSFunction *    Function private
        # v      jsval           Argument value (no conversion)
        # *      N/A             Skip this argument (no vararg)
        # /      N/A             End of required arguments
        # More info:
        # https://developer.mozilla.org/en/SpiderMonkey/JSAPI_Reference/JS_ConvertArguments
        self.args_js_types_conversions = {
            'b': ['JSBool',    'JS_ValueToBoolean'],
            'd': ['double',    'JS_ValueToNumber'],
            'I': ['double',    'JS_ValueToNumber'],    # double converted to string
            'i': ['int32_t',   'JSB_jsval_to_int32'],
            'j': ['int32_t',   'JSB_jsval_to_int32'],
            'u': ['uint32_t',  'JSB_jsval_to_uint32'],
            'c': ['uint16_t',  'JSB_jsval_to_uint16'],
        }

        self.args_js_special_type_conversions = {
            'S': ['JSB_jsval_to_NSString', 'NSString*'],
            'dict': ['JSB_jsval_to_NSDictionary', 'NSDictionary*'],
            'char*': ['JSB_jsval_to_charptr', 'const char*'],
            'o': ['JSB_jsval_to_NSObject', 'id'],
            'array': ['JSB_jsval_to_NSArray', 'NSArray*'],
            'set': ['JSB_jsval_to_NSSet', 'NSSet*'],
            'f': ['JSB_jsval_to_block_1', 'js_block'],
            'long':     ['JSB_jsval_to_long', 'long'],
            'longlong': ['JSB_jsval_to_longlong', 'long long'],
        }

    #
    # BEGIN Helper functions
    #
    def convert_to_python_type(self, v):
        l = v.lower()
        if l == 'true':
            return True
        elif l == 'false':
            return False
        return v

    # whether or not the method is a constructor
    def get_function(self, function_name):
        '''returns a function from function name'''
        funcs = self.bs['signatures']['function']
        for f in funcs:
            if f['name'] == function_name:
                return f
        raise ParseException("Function %s not found" % function_name)

    def is_class_constructor(self, method):
        if self.is_class_method(method) and 'retval' in method:
            retval = method['retval']
            dt = retval[0]['declared_type']

            # Should also check the naming convention. eg: 'spriteWith...'
            if dt == 'id':
                return True
        return False

    # whether or not the method is an initializer
    def is_method_initializer(self, method):
        # Is this is a method ?
        if not 'selector' in method:
            return False

        if 'retval' in method:
            retval = method['retval']
            dt = retval[0]['declared_type']

            if method['selector'].startswith('init') and dt == 'id':
                return True
        return False

    def get_struct_type_and_num_of_elements(self, struct):
        # PRECOND: Structure must be valid

        # BridgeSupport to TypedArray
        bs_to_type_array = {'c': 'js::ArrayBufferView::TYPE_INT8',
                            'C': 'js::ArrayBufferView::TYPE_UINT8',
                            's': 'js::ArrayBufferView::TYPE_INT16',
                            'S': 'js::ArrayBufferView::TYPE_UINT16',
                            'i': 'js::ArrayBufferView::TYPE_INT32',
                            'I': 'js::ArrayBufferView::TYPE_UINT32',
                            'f': 'js::ArrayBufferView::TYPE_FLOAT32',
                            'd': 'js::ArrayBufferView::TYPE_FLOAT64',
                              }

        inner = struct.replace('{', '')
        inner = inner.replace('{', '')
        inner = inner.replace('}', '')
        key, value = inner.split('=')

        k = value[0]
        if not k in bs_to_type_array:
            raise Exception('Structure cannot be converted')

        # returns type of structure and len
        return (bs_to_type_array[k], len(value))

    def get_name_for_manual_struct(self, struct_name):
        value = self.get_struct_property(struct_name, 'manual')
        if not value:
            return struct_name
        return value

    def get_struct_property(self, struct_name, property):
        try:
            return self.struct_properties[struct_name][property]
        except KeyError:
            return None

    def is_valid_structure(self, struct):
        # Only support non-nested structures of only one type
        # valids:
        #   {xxx=CCC}
        #   {xxx=ff}
        # invalids:
        #   {xxx=CC{yyy=C}}
        #   {xxx=fC}

        if not struct:
            return False

        if struct[0] == '{' and struct[-1] == '}' and len(struct.split('{')) == 2:
            inner = struct.replace('{', '')
            inner = inner.replace('{', '')
            inner = inner.replace('}', '')
            key, value = inner.split('=')
            # values should be of the same type
            previous = None
            for c in value:
                if previous != None:
                    if previous != c:
                        return False
                    previous = c
            return True
        return False

    def get_class_property(self, property, class_name):
        try:
            return self.class_properties[class_name][property]
        except KeyError:
            return None

    def is_class_method(self, method):
        return 'class_method' in method and method['class_method'] == 'true'

    def get_constant_property(self, property, default=None):
        try:
            v = self.constant_properties[property]
            v = self.convert_to_python_type(v)
            return v
        except KeyError:
            return default

    def get_number_of_arguments(self, function):
        ret = 0
        if 'arg' in function:
            return len(function['arg'])
        return ret

    #
    # END helper functions
    #
    def generate_pragma_mark(self, class_name, fd):
        pragm_mark = '''
/*
 * %s
 */
#pragma mark - %s
'''
        fd.write(pragm_mark % (class_name, class_name))

    def generate_autogenerated_prefix(self, fd):
        autogenerated_template = '''/*
* AUTOGENERATED FILE. DO NOT EDIT IT
* Generated by "%s -c %s" on %s
* Script version: %s
*/
#%s "jsb_config.h"
#if JSB_INCLUDE_%s

'''
        if self.compatible_with_cpp:
            import_name = 'include'
        else:
            import_name = 'import'

        name = self.namespace.upper()
        fd.write(autogenerated_template % (os.path.basename(sys.argv[0]), os.path.basename(sys.argv[2]), datetime.date.today(), JSB_VERSION, import_name, name))

        # Possible Imported files
        for i in self.import_files:
            if i and i != '':
                fd.write('#%s "%s"\n' % (import_name, i))

    def generate_autogenerate_suffix(self, fd):
        autogenerated_template = '''

#endif // JSB_INCLUDE_%s
'''
        name = self.namespace.upper()
        fd.write(autogenerated_template % name)

    def generate_retval(self, declared_type, js_type, method=None):

        if method and self.is_method_initializer(method):
            return '\tJS_SET_RVAL(cx, vp, JSVAL_TRUE);'

        conversion = self.convert_objc_to_js(declared_type, js_type)
        conversion = conversion % ({'objc_val': 'ret_val'})

        template = '''
\tJS_SET_RVAL(cx, vp, %s);
'''
        return template % (conversion)

    def validate_retval(self, method, class_name=None):
        # parse ret value
        if 'retval' in method:
            # Special case for initializer methods
            if self.is_method_initializer(method):
                return (None, None)

            # Special case for class constructors
            elif self.is_class_constructor(method):
                return ('o', class_name + '*')

            retval = method['retval'][0]
            return self.validate_argument(retval)

        return (None, None)

    def validate_argument(self, arg):

        t = arg['type']
        dt = arg['declared_type']

        # Treat 'id' as NSObject*
        if dt == 'id':
            dt = 'NSObject*'

        dt_class_name = dt.replace('*', '')

        # IMPORTANT: 1st search on declared types.
        # NSString should be treated as a special case, not as a generic object
        if dt in self.supported_declared_types:
            return (self.supported_declared_types[dt], dt)

        elif t in self.supported_types:
            return (self.supported_types[t], dt)

        # special case for Objects
        elif t == '@' and dt_class_name in self.supported_classes:
            return ('o', dt)

        # valid 'opaque' struct ?
        elif dt in self.struct_opaque:
            return ('N/A', dt)

        # valid manual struct ?
        elif dt in self.struct_manual:
            return ('N/A', dt)

        # valid automatic struct ?
        elif self.is_valid_structure(t):
            return (t, dt)

        raise ParseException("Unsupported argument: %s" % dt)

    def validate_arguments(self, method):
        args_js_type = []
        args_declared_type = []

        # parse arguments
        if 'arg' in method:
            args = method['arg']
            for arg in args:
                js_type, dt = self.validate_argument(arg)

                # Skip argument if they are none
                if js_type is not None and dt is not None:
                    args_js_type.append(js_type)
                    args_declared_type.append(dt)

        return (args_js_type, args_declared_type)

    def generate_argument_variadic_2_nsarray(self):
        template = '\tok &= JSB_jsvals_variadic_to_NSArray( cx, argvp, argc, &arg0 );\n'
        self.fd_mm.write(template)

    def convert_js_to_objc(self, js_type, objc_type):
        if objc_type in self.function_classes and self.generating_OOF:
            return 'JSB_jsval_to_c_class( cx, %(jsval)s, (void**)%(retval)s, NULL )'
        elif objc_type in self.struct_opaque:
            return 'JSB_jsval_to_opaque( cx, %(jsval)s, (void**)%(retval)s )'
        elif objc_type in self.struct_manual:
            new_name = self.get_name_for_manual_struct(objc_type)
            return 'JSB_jsval_to_%s( cx, %%(jsval)s, (%s*) %%(retval)s )' % (new_name, new_name)
        elif self.is_valid_structure(js_type):
            return 'JSB_jsval_to_struct( cx, %%(jsval)s, %%(retval)s, sizeof(%s) )' % (objc_type)
        elif js_type in self.args_js_types_conversions:
            js_convert = self.args_js_types_conversions[js_type][1]
            return js_convert + '( cx, %(jsval)s, %(retval)s )'
        elif js_type in self.args_js_special_type_conversions:
            js_convert = self.args_js_special_type_conversions[js_type][0]
            if js_type == 'f':
                return js_convert + '( cx, %(jsval)s, JS_THIS_OBJECT(cx, vp), %(retval)s )'
            else:
                return js_convert + '( cx, %(jsval)s, %(retval)s )'
        else:
            raise ParseException('Unsupported argument type: %s' % js_type)

    def convert_objc_to_js(self, objc_type, js_type):
        if objc_type in self.function_classes and self.generating_OOF:
            # remove '*' from class name
            klass = objc_type[:-1]
            template = 'JSB_jsval_from_c_class( cx, %%(objc_val)s, %s, %s, "%s" )'
            return template % ('JSB_%s_object' % klass, 'JSB_%s_class' % klass, klass)
        elif objc_type in self.struct_opaque:
            return 'JSB_jsval_from_opaque( cx, %(objc_val)s )'
        elif objc_type in self.struct_manual:
            new_name = self.get_name_for_manual_struct(objc_type)
            template = 'JSB_jsval_from_%s( cx, (%s)%%(objc_val)s )'
            return template % (new_name, objc_type)
        elif self.is_valid_structure(js_type):
            t, l = self.get_struct_type_and_num_of_elements(js_type)
            template = 'JSB_jsval_from_struct( cx, %d, &%%(objc_val)s, %s )'
            return template % (l, t)
        elif js_type in self.objc_to_js_conversions:
            return self.objc_to_js_conversions[js_type]
        else:
            raise Exception("Invalid key: %s" % js_type)

    def generate_argument(self, i, arg_js_type, arg_declared_type):
        template = self.convert_js_to_objc(arg_js_type, arg_declared_type)
        template = template % ({
            "jsval": "*argvp++",
            "retval": "&arg%d" % i
        })
        return "\tok &= %s;\n" % template

    # The type of the value returned by the JS conversion function
    def get_conversion_return_type(self, js_type, objc_type):
        if objc_type in self.struct_opaque or objc_type in self.function_classes:
            return objc_type
        elif objc_type in self.struct_manual:
            return objc_type
        elif self.is_valid_structure(js_type):
            return objc_type
        elif js_type in self.args_js_types_conversions:
            return self.args_js_types_conversions[js_type][0]
        elif js_type in self.args_js_special_type_conversions:
            return self.args_js_special_type_conversions[js_type][1]
        else:
            raise ParseException('Unsupported argument type: %s' % js_type)

    def generate_arguments(self, args_declared_type, args_js_type, properties={}):
        # First  time
        self.fd_mm.write('\tjsval *argvp = JS_ARGV(cx,vp);\n')
        self.fd_mm.write('\tJSBool ok = JS_TRUE;\n')

        # first_arg is used by "OO Functions". The first argument should be "self", so argv[0] is skipped in those cases
        first_arg = properties.get('first_arg', 0)

        # Declare variables
        declared_vars = '\t'
        for i, arg in enumerate(args_js_type):
            if i < first_arg:
                continue

            arg_type = self.get_conversion_return_type(arg, args_declared_type[i])

            declared_vars += '%s arg%d;' % (arg_type, i)
            declared_vars += ' '
        self.fd_mm.write('%s\n\n' % declared_vars)

        # Optional Arguments ? Used when merging methods
        min_args = properties.get('min_args', None)
        max_args = properties.get('max_args', None)
        if min_args != max_args:
            optional_args = min_args
        else:
            optional_args = None

        # Use variables

        # Special case for variadic_2_nsarray
        if 'variadic_2_array' in properties:
            self.generate_argument_variadic_2_nsarray()

        else:
            for i, arg in enumerate(args_js_type):

                if i < first_arg:
                    continue

                if optional_args != None and i >= optional_args:
                    self.fd_mm.write('\tif (argc >= %d) {\n\t' % (i + 1))

                self.fd_mm.write(self.generate_argument(i, arg, args_declared_type[i]))

                if optional_args != None and i >= optional_args:
                    self.fd_mm.write('\t}\n')

        self.fd_mm.write('\tJSB_PRECONDITION2(ok, cx, JS_FALSE, "Error processing arguments");\n')

    #
    # Externs related
    #
    def externs_create_file(self):
        self.externs_fd = open('%s_externs.js' % (self.namespace), 'w')

    def externs_close_file(self):
        self.externs_fd.close()

    def externs_write_function(self, func_name):
        js_body = 'function %s(){};\n'
        self.externs_fd.write(js_body % func_name)

    def generate_externs(self):
        if len(self.bound_js_functions) > 0:
            self.externs_create_file()
            for function_name in self.bound_js_functions:
                self.externs_write_function(function_name)
            self.externs_close_file()

#
#
# Generates Classes
#
#
class JSBGenerateClasses(JSBGenerate):
    def __init__(self, config):
        super(JSBGenerateClasses, self).__init__(config)

    #
    # BEGIN helper functions
    #
    def create_files(self):
        self.fd_h = open('%s%s_classes.h' % (BINDINGS_PREFIX, self.namespace), 'w')
        self.generate_class_header_prefix()
        self.fd_mm = open('%s%s_classes.mm' % (BINDINGS_PREFIX, self.namespace), 'w')

    def convert_class_name_to_js(self, class_name):
        # rename rule ?
        if class_name in self.class_properties and 'name' in self.class_properties[class_name]:
            name = self.class_properties[class_name]['name']
            name = name.replace('"', '')
            return name

        # Prefix rule ?
        if class_name.startswith(self.class_prefix):
            class_name = class_name[len(self.class_prefix):]

        return class_name

    def convert_selector_name_to_native(self, name):
        return name.replace(':', '_')

    def convert_selector_name_to_js(self, class_name, selector):
        # Does it have a rename rule ?
        try:
            return self.method_properties[class_name][selector]['name']
        except KeyError:
            pass

        # Is it a property ?
        try:
            if selector in self.complement[class_name]['properties']:
                # Does it have a properties ?
#                props = self.complement[class_name]['properties'][selector]
#                print selector
#                props = self.parse_objc_properties(props)
#                print props
#                if 'getter' in props:
#                    ret = props['getter']
#                    print ret
#                    xxxx
#                else
                ret = 'get%s%s' % (selector[0].capitalize(), selector[1:])
                return ret
        except KeyError:
            pass

        name = ''
        parts = selector.split(':')
        for i, arg in enumerate(parts):
            if i == 0:
                name += arg
            elif arg:
                name += arg[0].capitalize() + arg[1:]

        return name

    def parse_objc_properties(self, props):
        ret = {}
        # only get first element of array
        p = props[0].split(',')
        for k in p:
            key_value = k.split('=')
            key = key_value[0].strip()
            if len(key_value) > 1:
                value = key_value[1].strip()
            else:
                value = None
            ret[key] = value
        return ret

    def get_method(self, class_name, method_name):
        for klass in self.bs['signatures']['class']:
            if klass['name'] == class_name:
                for m in klass['method']:
                    if m['selector'] == method_name:
                        return m

        # Not found... search in protocols
        if 'informal_protocol' in self.bs['signatures'] and 'protocols' in self.complement[class_name]:
            list_of_protocols = self.bs['signatures']['informal_protocol']
            protocols = self.complement[class_name]['protocols']
            for protocol in protocols:
                for ip in list_of_protocols:
                    # protocol match ?
                    if ip['name'] == protocol:
                        # traverse method then
                        for m in ip['method']:
                            if m['selector'] == method_name:
                                return m

        raise MethodNotFoundException("Method not found for %s # %s" % (class_name, method_name))

    def get_method_type(self, method):
        if self.is_class_constructor(method):
            method_type = METHOD_CONSTRUCTOR
        elif self.is_class_method(method):
            method_type = METHOD_CLASS
        elif self.is_method_initializer(method):
            method_type = METHOD_INIT
        else:
            method_type = METHOD_REGULAR

        return method_type

    def get_callback_args_for_method(self, method):
        method_name = method['selector']
        method_args = method_name.split(':')

        full_args = []
        args = []

        if 'arg' in method:
            for i, arg in enumerate(method['arg']):
                full_args.append(method_args[i] + ':')
                full_args.append('(' + arg['declared_type'] + ')')
                full_args.append(arg['name'] + ' ')

                args.append(method_args[i] + ':')
                args.append(arg['name'] + ' ')
            return [''.join(full_args), ''.join(args)]
        return method_name, method_name

    def get_parent_class(self, class_name):
        try:
            parent = self.complement[class_name]['subclass']
        except KeyError:
            return None
        return parent

    def get_class_method(self, class_name):
        class_methods = []

        klass = None
        list_of_classes = self.bs['signatures']['class']
        for k in list_of_classes:
            if k['name'] == class_name:
                klass = k

        if not klass:
            raise Exception("Base class not found: %s" % class_name)

        for m in klass['method']:
            if self.is_class_method(m):
                class_methods.append(m)
        return class_methods

    def inherits_class_methods(self, class_name, methods_to_parse=[]):
        i = self.get_class_property('inherit_class_methods', class_name)
        if i != None:
            return i

        inherit = self._inherit_class_methods.lower()
        if inherit == 'false':
            return False
        elif inherit == 'true':
            return True
        elif inherit == 'auto':
            for m in methods_to_parse:
                if self.is_class_constructor(m):
                    return False
        else:
            raise Exception("Unknown value for inherit_class_methods: %s", self._inherit_class_methods)

        return True

    def requires_swizzle(self, class_name):
        if class_name in self.callback_methods:
            for m in self.callback_methods[class_name]:
                if not self.get_method_property(class_name, m, 'no_swizzle'):
                    return True
        return False

    def get_method_property(self, class_name, method_name, prop):
        try:
            return self.method_properties[class_name][method_name][prop]
        except KeyError:
            return None
    #
    # END helper functions
    #

    #
    # "class" constructor and destructor
    #
    def generate_constructor(self, class_name):

        # Global Variables
        # JSB_CCNode
        # JSB_CCNode
        constructor_globals = '''
JSClass* %s_class = NULL;
JSObject* %s_object = NULL;
'''

        # 1: JSB_CCNode,
        # 2: JSB_CCNode,
        # 8: possible callback code
        constructor_template = '''// Constructor
JSBool %s_constructor(JSContext *cx, uint32_t argc, jsval *vp)
{
\tJSObject *jsobj = [%s createJSObjectWithRealObject:nil context:cx];
\tJS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
\treturn JS_TRUE;
}
'''
        proxy_class_name = '%s%s' % (PROXY_PREFIX, class_name)
        self.fd_mm.write(constructor_globals % (proxy_class_name, proxy_class_name))
        self.fd_mm.write(constructor_template % (proxy_class_name, proxy_class_name))

    def generate_destructor(self, class_name):
        destructor_template = '''
// Destructor
void %s_finalize(JSFreeOp *fop, JSObject *obj)
{
\tCCLOGINFO(@"jsbindings: finalizing JS object %%p (%s)", obj);
//\tJSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(obj);
//\tif (proxy) {
//\t\t[[proxy realObj] release];
//\t}
\tJSB_del_proxy_for_jsobject( obj );
}
'''
        proxy_class_name = '%s%s' % (PROXY_PREFIX, class_name)
        self.fd_mm.write(destructor_template % (proxy_class_name,
                                                    class_name))

    def generate_ctor_method(self, klass_name):
        template = '''
// 'ctor' method. Needed for subclassing native objects in JS
JSBool JSB_%s_ctor(JSContext *cx, uint32_t argc, jsval *vp) {

\tJSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
\tJSB_PRECONDITION2( !JSB_get_proxy_for_jsobject(obj), cx, JS_FALSE, "Object already initialzied. error" );

\tJSB_%s *proxy = [[JSB_%s alloc] initWithJSObject:obj class:[%s class]];
\t[[proxy class] swizzleMethods];

\tJS_SET_RVAL(cx, vp, JSVAL_TRUE);

\treturn JS_TRUE;
}
'''
        self.fd_mm.write(template % (klass_name, klass_name, klass_name, klass_name))

    #
    # Method generator functions
    #
    def generate_method_call_to_real_object(self, selector_name, num_of_args, ret_js_type, args_declared_type, args_js_type, class_name, method_type):

        args = selector_name.split(':')

        if method_type == METHOD_INIT:
            prefix = '\t%s *real = [(%s*)[proxy.klass alloc] ' % (class_name, class_name)
            suffix = '\n\t[proxy setRealObj: real];\n\t[real autorelease];\n'
            suffix += '\n\tobjc_setAssociatedObject(real, &JSB_association_proxy_key, proxy, OBJC_ASSOCIATION_RETAIN);'
            suffix += '\n\t[proxy release];'
        elif method_type == METHOD_REGULAR:
            prefix = '\t%s *real = (%s*) [proxy realObj];\n\t' % (class_name, class_name)
            suffix = ''
            if ret_js_type:
                prefix = prefix + 'ret_val = '
            prefix = prefix + '[real '
        elif method_type == METHOD_CONSTRUCTOR:
            prefix = '\tret_val = [%s ' % (class_name)
            suffix = ''
        elif method_type == METHOD_CLASS:
            if not ret_js_type:
                prefix = '\t[%s ' % (class_name)
            else:
                prefix = '\tret_val = [%s ' % (class_name)
            suffix = ''
        else:
            raise Exception('Invalid method type')

        call = ''

        for i, arg in enumerate(args):
            if num_of_args == 0:
                call += arg
            elif i + 1 > num_of_args:
                break
            elif arg:   # empty arg?
                if args_js_type[i] == 'o':
                    call += '%s:arg%d ' % (arg, i)
                else:
                    # cast needed to prevent compiler errors
                    call += '%s:(%s)arg%d ' % (arg, args_declared_type[i], i)

        call += ' ];'

        return '%s%s%s' % (prefix, call, suffix)

    def generate_method_prefix(self, class_name, method, num_of_args, method_type):
        # JSB_CCNode, setPosition
        # "!" or ""
        # proxy.initialized = YES (or nothing)
        template_methodname = '''
JSBool %s_%s%s(JSContext *cx, uint32_t argc, jsval *vp) {
'''
        template_init = '''
\tJSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
\tJSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsthis);

\tJSB_PRECONDITION2( proxy && %s[proxy realObj], cx, JS_FALSE, "Invalid Proxy object");
'''

        selector = method['selector']
        converted_name = self.convert_selector_name_to_native(selector)

        # method name
        class_method = '_static' if self.is_class_method(self.current_method) else ''
        self.fd_mm.write(template_methodname % (PROXY_PREFIX + class_name, converted_name, class_method))

        # method asserts for instance methods
        if method_type == METHOD_INIT or method_type == METHOD_REGULAR:
            assert_init = '!' if method_type == METHOD_INIT else ''
            self.fd_mm.write(template_init % assert_init)

        try:
            # Does it have optional arguments ?
            properties = self.method_properties[class_name][selector]
            min_args = properties.get('min_args', None)
            max_args = properties.get('max_args', None)
            if min_args != max_args:
                method_assert_on_arguments = '\tJSB_PRECONDITION2( argc >= %d && argc <= %d , cx, JS_FALSE, "Invalid number of arguments" );\n' % (min_args, max_args)
            elif 'variadic_2_array' in properties:
                method_assert_on_arguments = '\tJSB_PRECONDITION2( argc >= 0, cx, JS_FALSE, "Invalid number of arguments" );\n'
            else:
                # default
                method_assert_on_arguments = '\tJSB_PRECONDITION2( argc == %d, cx, JS_FALSE, "Invalid number of arguments" );\n' % num_of_args
        except KeyError:
            # No, it only has required arguments
            method_assert_on_arguments = '\tJSB_PRECONDITION2( argc == %d, cx, JS_FALSE, "Invalid number of arguments" );\n' % num_of_args
        self.fd_mm.write(method_assert_on_arguments)

    def generate_method_suffix(self):
        end_template = '''
\treturn JS_TRUE;
}
'''
        self.fd_mm.write(end_template)

    def generate_method(self, class_name, method):

        method_name = method['selector']

        # Skip 'callback' and 'ignore' methods
        # This should be before "manual", since "callback" and "ignore" have precedence over "manual"
        try:
            if 'callback' in self.method_properties[class_name][method_name]:
                raise ParseException('Method defined as callback. Ignoring.')
            if 'ignore' in self.method_properties[class_name][method_name]:
                raise ParseException('Explicitly ignoring method')
        except KeyError:
            pass

        #
        if self.get_method_property(class_name, method_name, 'manual'):
            sys.stderr.write('Ignoring method %s # %s. It should be manually generated\n' % (class_name, method_name))
            return True

        # Variadic methods are not supported
        if 'variadic' in method and method['variadic'] == 'true':
            raise ParseException('variadic arguments not supported.')

        args_js_type, args_declared_type = self.validate_arguments(method)
        ret_js_type, ret_declared_type = self.validate_retval(method, class_name)

        method_type = self.get_method_type(method)

        num_of_args = len(args_declared_type)

        # writes method description
        self.fd_mm.write('\n// Arguments: %s\n// Ret value: %s (%s)' % (', '.join(args_declared_type), ret_declared_type, ret_js_type))

        self.generate_method_prefix(class_name, method, num_of_args, method_type)

        try:
            properties = self.method_properties[class_name][method['selector']]
        except KeyError:
            properties = {}

        # Optional Args ?
        min_args = properties.get('min_args', None)
        max_args = properties.get('max_args', None)
        if min_args != max_args:
            optional_args = min_args
        else:
            optional_args = None

        total_args = self.get_number_of_arguments(method)
        if total_args > 0:
            self.generate_arguments(args_declared_type, args_js_type, properties)

        if ret_js_type:
            self.fd_mm.write('\t%s ret_val;\n' % (ret_declared_type))

        if optional_args != None:
            else_str = ''
            for i in xrange(max_args + 1):
                if i in properties['calls']:
                    call_real = self.generate_method_call_to_real_object(properties['calls'][i], i, ret_js_type, args_declared_type, args_js_type, class_name, method_type)
                    self.fd_mm.write('\n\t%sif( argc == %d ) {\n\t%s\n\t}' % (else_str, i, call_real))
                    else_str = 'else '
            self.fd_mm.write('\n\telse\n\t\tJSB_PRECONDITION2(NO, cx, JS_FALSE, "Error in number of arguments");\n\n')

        else:
            call_real = self.generate_method_call_to_real_object(method_name, num_of_args, ret_js_type, args_declared_type, args_js_type, class_name, method_type)
            self.fd_mm.write('\n%s\n' % call_real)

        ret_string = self.generate_retval(ret_declared_type, ret_js_type, method)
        if not ret_string:
            raise ParseException('invalid return string')

        self.fd_mm.write(ret_string)

        self.generate_method_suffix()

        return True

    def generate_methods(self, class_name, klass):
        ok_methods = []
        ok_method_name = []

        # Parse methods defined in the Class
        self.is_a_protocol = False
        for m in klass['method']:
            self.current_method = m

            try:
                self.generate_method(class_name, m)
                ok_methods.append(m)
                ok_method_name.append(m['selector'])
            except ParseException, e:
                sys.stderr.write('NOT OK: "%s#%s" Error: %s\n' % (class_name, m['selector'], str(e)))

        self.current_method = None

        self.is_a_protocol = True

        # Parse methods defined in the Protocol
        if class_name in self.complement and 'informal_protocol' in self.bs['signatures']:
            list_of_protocols = self.bs['signatures']['informal_protocol']
            protocols = self.complement[class_name]['protocols']
            for protocol in protocols:
                for p in list_of_protocols:
                    # XXX Super slow
                    if p['name'] == protocol:

                        # Get the method object
                        for m in p['method']:
                            method_name = m['selector']

                            # avoid possible duplicates between Protocols and Classes
                            if not method_name in ok_method_name:
                                self.current_method = m
                                try:
                                    self.generate_method(class_name, m)
                                    ok_methods.append(m)
                                    ok_method_name.append(m['selector'])
                                except ParseException, e:
                                    sys.stderr.write('NOT OK: "%s#%s" Error: %s\n' % (class_name, m['selector'], str(e)))

        # Parse class methods from base classes
        parent = self.get_parent_class(class_name)
        while self.inherits_class_methods(class_name, ok_methods) and (parent != None) and (not parent in self.classes_to_ignore):
            class_methods = self.get_class_method(parent)
            for cm in class_methods:
                if not cm['selector'] in ok_method_name:
                    self.current_method = cm
                    try:
                        self.generate_method(class_name, cm)
                        ok_methods.append(cm)
                        ok_method_name.append(cm['selector'])
                    except ParseException, e:
                        sys.stderr.write('NOT OK: "%s#%s" Error: %s\n' % (class_name, cm['selector'], str(e)))
            parent = self.get_parent_class(parent)

        self.current_method = None
        self.is_a_protocol = False

        return ok_methods

    def generate_callback_code(self, class_name):
        # CCNode
        template_prefix = '@implementation %s (JSBindings)\n'

        # BOOL - ccMouseUp:(NSEvent*)
        # PROXYJS_CCNode
        template_header = '''
-(%s) %s%s
{
%s'''
        template_super = '%s'
        template_body = '''\
\t%s *proxy = objc_getAssociatedObject(self, &JSB_association_proxy_key);
\tif( proxy )
\t\t%s[proxy %s];
'''
        template_end = '''\
%s
}
'''
        template_suffix = '@end\n'

        proxy_class_name = PROXY_PREFIX + class_name

        if class_name in self.callback_methods:

            self.fd_mm.write(template_prefix % class_name)
            for m in self.callback_methods[class_name]:

                real_method = self.get_method(class_name, m)
                fullargs, args = self.get_callback_args_for_method(real_method)
                js_ret_val, dt_ret_val = self.validate_retval(real_method, class_name)

                if dt_ret_val != 'void':
                    pre_ret = '\t%s ret = nil;\n' % dt_ret_val
                    assign_ret = 'ret = '
                    post_ret = '\treturn ret;\n'
                else:
                    pre_ret = ''
                    assign_ret = ''
                    post_ret = ''
                no_super = self.get_method_property(class_name, m, 'no_super')
                no_swizzle = self.get_method_property(class_name, m, 'no_swizzle')
                if not no_swizzle:
                    swizzle_prefix = 'JSHook_'
                    if no_super:
                        call_native = ''
                    else:
                        call_native = '\t//1st call native, then JS. Order is important\n\t[self JSHook_%s];\n' % (args)
                else:
                    swizzle_prefix = ''
                    call_native = ''

                self.fd_mm.write(template_header % (dt_ret_val, swizzle_prefix, fullargs,
                                                pre_ret))
                self.fd_mm.write(template_super % call_native)

                self.fd_mm.write(template_body % (proxy_class_name,
                                                assign_ret,
                                                args))
                self.fd_mm.write(template_end % post_ret)

            self.fd_mm.write(template_suffix)

    def generate_class_header_prefix(self):
        self.generate_autogenerated_prefix(self.fd_h)

    def generate_class_header(self, class_name, parent_name):
        # JSPROXXY_CCNode
        # manual_methods
        # JSPROXXY_CCNode
        # JSB_CCNode, JSB_NSObject
        header_template = '''
#ifdef __cplusplus
extern "C" {
#endif

void %s_createClass(JSContext *cx, JSObject* globalObj, const char* name );

%s

extern JSObject *%s_object;
extern JSClass *%s_class;

#ifdef __cplusplus
}
#endif

/* Proxy class */
@interface %s : %s
{
}
'''
        header_template_callbacks = '''
/* Manually generated callbacks */
@interface %s (Manual)
%s
@end
'''

        header_template_end = '@end\n'

        proxy_class_name = '%s%s' % (PROXY_PREFIX, class_name)

        self.generate_pragma_mark(class_name, self.fd_h)

        manual_methods = ''
        manual_callbacks = ''
        method_sig = 'JSBool %s_%s%s(JSContext *cx, uint32_t argc, jsval *vp);\n'
        callback_sig = '-(%s) %s;\n'

        # 1)
        # Add manual methods: manually defined, or callbacks
        if class_name in self.manual_methods:
            manual_methods += '// Manually generated methods\n'

            for method_name in self.manual_methods[class_name]:
                try:
                    method = self.get_method(class_name, method_name)

                    if class_name in self.callback_methods and method_name in self.callback_methods[class_name]:
                        # Is this a manual callback ?
                        full_args, args = self.get_callback_args_for_method(method)
                        js_retval, dt_retval = self.validate_retval(method, class_name)
                        manual_callbacks += callback_sig % (dt_retval, full_args)
                    else:
                        # or is this a manual method ?
                        class_method = '_static' if self.is_class_method(method) else ''
                        n = self.convert_selector_name_to_native(method_name)
                        manual_methods += method_sig % (proxy_class_name, n, class_method)
                except MethodNotFoundException, e:
                    sys.stderr.write('WARN: Ignoring regular expression rule. Method not found: %s\n' % str(e))

        # 2)
        # Add new methods that are not defined in the native header
        if class_name in self.js_new_methods:
            for k in self.js_new_methods[class_name]:
                manual_methods += method_sig % (proxy_class_name, k, '')

        self.fd_h.write(header_template % (proxy_class_name,
                                                manual_methods,
                                                proxy_class_name,
                                                proxy_class_name,
                                                proxy_class_name, PROXY_PREFIX + parent_name,
                                                ))
        self.fd_h.write(header_template_end)

        if manual_callbacks:
            self.fd_h.write(header_template_callbacks % (proxy_class_name, manual_callbacks))

    def generate_callback_args(self, method):
        no_args = 'jsval *argv = NULL; unsigned argc=0;\n'
        with_args = '''unsigned argc=%d;
\t\t\tjsval argv[%d];
'''

        # Convert arguments to callback method (objc to js)
        if 'arg' in method:
            args_len = self.get_number_of_arguments(method)
            for i, arg in enumerate(method['arg']):
                t, dt = self.validate_argument(arg)

                conversion = self.convert_objc_to_js(dt, t)
                conversion = conversion % ({'objc_val': arg['name']})

                with_args += "\t\t\targv[%d] = %s;\n" % (i, conversion)
            return with_args % (args_len, args_len)
        return no_args

    def generate_implementation_callback(self, class_name):
        # BOOL ccMouseUp NSEvent*
        # ccMouseUp
        # ccMouseUp
        template_header = '''
-(%s) %s
{
%s'''
        template_body = '''\
\tif (_jsObj) {
\t\tJSContext* cx = [[JSBCore sharedInstance] globalContext];
\t\tJSBool found;
\t\tJSB_ENSURE_AUTOCOMPARTMENT(cx, _jsObj);
\t\tJS_HasProperty(cx, _jsObj, "%s", &found);
\t\tif (found == JS_TRUE) {
\t\t\tjsval rval, fval;
\t\t\t%s
\t\t\tJS_GetProperty(cx, _jsObj, "%s", &fval);
\t\t\tJS_CallFunctionValue(cx, _jsObj, fval, argc, argv, &rval);
'''
        template_ret = '''\
\t\t\t%(ret_type)s ret_val;
\t\t\tJSBool ok = %(convert)s;
\t\t\tret = ret_val;
\t\t\tJSB_PRECONDITION2( ok, cx, ret, "Error converting return value to object");
'''
        template_end = '''\
\t\t}
\t}
\t%s
}
'''
        if class_name in self.callback_methods:
            for m in self.callback_methods[class_name]:

                # ignore manual
                if class_name in self.manual_methods and m in self.manual_methods[class_name]:
                    continue

                method = self.get_method(class_name, m)
                full_args, args = self.get_callback_args_for_method(method)
                js_retval, dt_retval = self.validate_retval(method, class_name)

                if dt_retval != 'void':
                    pre_ret = '\t%s ret = nil;\n' % dt_retval
                    post_ret = 'return ret;'
                else:
                    pre_ret = ''
                    post_ret = ''

                converted_args = self.generate_callback_args(method)

                js_name = self.convert_selector_name_to_js(class_name, m)
                self.fd_mm.write(template_header % (dt_retval, full_args,
                                    pre_ret))
                self.fd_mm.write(template_body % (js_name,
                                                converted_args,
                                                js_name))

                if dt_retval != 'void':
                    template = self.convert_js_to_objc(js_retval, dt_retval)
                    template = template % ({
                        "jsval": "rval",
                        "retval": "&ret_val"
                    })
                    self.fd_mm.write(template_ret % ({
                        "convert": template,
                        "ret_type": self.get_conversion_return_type(js_retval, dt_retval),
                        "dt_retval": dt_retval
                    }))
                self.fd_mm.write(template_end % post_ret)

    def generate_implementation_swizzle(self, class_name):
        # CCNode
        # CCNode
        template_prefix = '''
+(void) swizzleMethods
{
\t[super swizzleMethods];

\tstatic BOOL %s_already_swizzled = NO;
\tif( ! %s_already_swizzled ) {
\t\tNSError *error;
'''
        # CCNode, onEnter, onEnter
        template_middle = '''
\t\tif( ! [%s jr_swizzleMethod:@selector(%s) withMethod:@selector(JSHook_%s) error:&error] )
\t\t\tNSLog(@"Error swizzling %%@", error);
'''
        # CCNode
        template_suffix = '''
\t\t%s_already_swizzled = YES;
\t}
}
'''
        if class_name in self.callback_methods:
            self.fd_mm.write(template_prefix % (class_name, class_name))
            for m in self.callback_methods[class_name]:

                if not self.get_method_property(class_name, m, 'no_swizzle'):
                    self.fd_mm.write(template_middle % (class_name, m, m))

            self.fd_mm.write(template_suffix % (class_name))

    def generate_implementation(self, class_name):
        create_object_template_prefix = '''
+(JSObject*) createJSObjectWithRealObject:(id)realObj context:(JSContext*)cx
{
\tJSObject *jsobj = JS_NewObject(cx, %s_class, %s_object, NULL);
\t%s *proxy = [[%s alloc] initWithJSObject:jsobj class:[%s class]];
\t[proxy setRealObj:realObj];

\tif( realObj ) {
\t\tobjc_setAssociatedObject(realObj, &JSB_association_proxy_key, proxy, OBJC_ASSOCIATION_RETAIN);
\t\t[proxy release];
\t}

\t[self swizzleMethods];
'''

        create_object_template_suffix = '''
\treturn jsobj;
}
'''
        proxy_class_name = '%s%s' % (PROXY_PREFIX, class_name)

        self.fd_mm.write('\n@implementation %s\n' % proxy_class_name)

        self.fd_mm.write(create_object_template_prefix % (proxy_class_name, proxy_class_name,
                                                             proxy_class_name, proxy_class_name,
                                                             class_name
                                                             ))

        self.fd_mm.write(create_object_template_suffix)

        if self.requires_swizzle(class_name):
            self.generate_implementation_swizzle(class_name)

        self.generate_implementation_callback(class_name)

        self.fd_mm.write('\n@end\n')

    def generate_createClass_function(self, class_name, parent_name, ok_methods):
        # 1-12: JSB_CCNode
        implementation_template = '''
void %s_createClass(JSContext *cx, JSObject* globalObj, const char* name )
{
\t%s_class = (JSClass *)calloc(1, sizeof(JSClass));
\t%s_class->name = name;
\t%s_class->addProperty = JS_PropertyStub;
\t%s_class->delProperty = JS_PropertyStub;
\t%s_class->getProperty = JS_PropertyStub;
\t%s_class->setProperty = JS_StrictPropertyStub;
\t%s_class->enumerate = JS_EnumerateStub;
\t%s_class->resolve = JS_ResolveStub;
\t%s_class->convert = JS_ConvertStub;
\t%s_class->finalize = %s_finalize;
\t%s_class->flags = %s;
'''

        # Properties
        properties_template = '''
\tstatic JSPropertySpec properties[] = {
\t\t{0, 0, 0, 0, 0}
\t};
'''
        functions_template_start = '\tstatic JSFunctionSpec funcs[] = {\n'
        functions_template_end = '\t\tJS_FS_END\n\t};\n'

        static_functions_template_start = '\tstatic JSFunctionSpec st_funcs[] = {\n'
        static_functions_template_end = '\t\tJS_FS_END\n\t};\n'

        # 1: JSB_CCNode
        # 2: JSB_NSObject
        # 3-4: JSB_CCNode
        init_class_template = '''
\t%s_object = JS_InitClass(cx, globalObj, %s_object, %s_class, %s_constructor,0,properties,funcs,NULL,st_funcs);
\tJSBool found;
\tJS_SetPropertyAttributes(cx, globalObj, name, JSPROP_ENUMERATE | JSPROP_READONLY, &found);
}
'''
        proxy_class_name = '%s%s' % (PROXY_PREFIX, class_name)
        proxy_parent_name = '%s%s' % (PROXY_PREFIX, parent_name)

        reserved_slots = self.get_class_property('reserved_slots', class_name)
        flags = "JSCLASS_HAS_RESERVED_SLOTS(%s)" % reserved_slots if reserved_slots != None else "0"

        self.fd_mm.write(implementation_template % (proxy_class_name,
                                                        proxy_class_name, proxy_class_name, proxy_class_name,
                                                        proxy_class_name, proxy_class_name, proxy_class_name,
                                                        proxy_class_name, proxy_class_name, proxy_class_name,
                                                        proxy_class_name, proxy_class_name, proxy_class_name,
                                                        flags,
                                                        ))

        self.fd_mm.write(properties_template)

        js_fn = '\t\tJS_FN("%s", %s, %d, JSPROP_PERMANENT %s),\n'

        instance_method_buffer = ''
        class_method_buffer = ''

        # 1)
        # Add "approved" native methods to JS
        for method in ok_methods:

            num_args = self.get_number_of_arguments(method)

            class_method = '_static' if self.is_class_method(method) else ''

            js_name = self.convert_selector_name_to_js(class_name, method['selector'])
            cb_name = self.convert_selector_name_to_native(method['selector'])

            if self.is_class_constructor(method):
                entry = js_fn % (js_name, proxy_class_name + '_' + cb_name + class_method, num_args, '| JSPROP_ENUMERATE')  # | JSFUN_CONSTRUCTOR
            else:
                entry = js_fn % (js_name, proxy_class_name + '_' + cb_name + class_method, num_args, '| JSPROP_ENUMERATE')

            if self.is_class_method(method):
                class_method_buffer += entry
            else:
                instance_method_buffer += entry

        # 2)
        # Add callback methods pointing to a void function.
        # This allows calling "this._super()" from JS
        if class_name in self.callback_methods:
            for m in self.callback_methods[class_name]:
                js_name = self.convert_selector_name_to_js(class_name, m)
                instance_method_buffer += js_fn % (js_name, PROXY_PREFIX + 'do_nothing', 0, '| JSPROP_ENUMERATE')

        # 3)
        # Adds methods that does not exist in native, but should be added in JS
        if class_name in self.js_new_methods:
            m = self.js_new_methods[class_name]
            for k in m.keys():
                js_name = k
                instance_method_buffer += js_fn % (js_name, PROXY_PREFIX + class_name + '_' + k, m[k], '| JSPROP_ENUMERATE')

        # 4)
        # Add "ctor", to allow subclassing native classes from JS
        instance_method_buffer += js_fn % ("ctor", "%s%s_ctor" % (PROXY_PREFIX, class_name), 0, '| JSPROP_ENUMERATE')

        # instance methods entry point
        self.fd_mm.write(functions_template_start)
        self.fd_mm.write(instance_method_buffer)
        self.fd_mm.write(functions_template_end)

        # class methods entry point
        self.fd_mm.write(static_functions_template_start)
        self.fd_mm.write(class_method_buffer)
        self.fd_mm.write(static_functions_template_end)

        self.fd_mm.write(init_class_template % (proxy_class_name, proxy_parent_name, proxy_class_name, proxy_class_name))

    def generate_class_mm_prefix(self):
        import_template = '''
// needed for callbacks from objective-c to JS
#import <objc/runtime.h>
#import "JRSwizzle.h"

#import "jsfriendapi.h"
#import "jsb_config.h"
#import "jsb_core.h"

#import "%s%s_classes.h"

'''

        self.generate_autogenerated_prefix(self.fd_mm)
        self.fd_mm.write(import_template % (BINDINGS_PREFIX, self.namespace))

    def generate_class_mm(self, klass, class_name, parent_name):
        self.generate_pragma_mark(class_name, self.fd_mm)
        self.generate_constructor(class_name)
        self.generate_destructor(class_name)
        self.generate_ctor_method(class_name)

        ok_methods = self.generate_methods(class_name, klass)

        self.generate_createClass_function(class_name, parent_name, ok_methods)
        self.generate_implementation(class_name)

        self.generate_callback_code(class_name)

    def generate_class_binding(self, class_name):
        # Ignore NSObject. Already registered
        if not class_name or class_name in self.classes_to_ignore or class_name in self.parsed_classes or class_name in self.class_manual:
            return

        parent = self.complement[class_name]['subclass']
        self.generate_class_binding(parent)

        self.parsed_classes.append(class_name)

        signatures = self.bs['signatures']
        classes = signatures['class']
        klass = None

        parent_name = self.complement[class_name]['subclass']

        # XXX: Super slow. Add them into a dictionary
        for c in classes:
            if c['name'] == class_name:
                klass = c
                break

        if not klass:
            raise Exception("Class not found: '%s'. Check file: '%s'" % (class_name, self.bridgesupport_files))

        self.generate_class_mm(klass, class_name, parent_name)
        self.generate_class_header(class_name, parent_name)

    def generate_class_registration(self, klass):
        # only supported classes
        if not klass or klass in self.classes_to_ignore or klass in self.class_manual:
            return

        if not klass in self.classes_registered:
            parent = self.complement[klass]['subclass']
            self.generate_class_registration(parent)

            class_name = self.convert_class_name_to_js(klass)

            self.class_registration_file.write('%s%s_createClass(_cx, %s, "%s");\n' % (PROXY_PREFIX, klass, self.namespace, class_name))
            self.classes_registered.append(klass)

    def generate_classes_registration(self):
        self.classes_registered = []

        self.class_registration_file = open('%s%s_classes_registration.h' % (BINDINGS_PREFIX, self.namespace), 'w')
        self.generate_autogenerated_prefix(self.class_registration_file)

        for klass in self.supported_classes:
            self.generate_class_registration(klass)

        self.generate_autogenerate_suffix(self.class_registration_file)

        self.class_registration_file.close()

    def generate_bindings(self):
        '''Main entry point. Generates the JS bindigns'''
        self.create_files()
        self.generate_class_mm_prefix()

        for klass in self.classes_to_bind:
            if not klass in self.class_manual:
                self.generate_class_binding(klass)

        self.generate_autogenerate_suffix(self.fd_h)
        self.generate_autogenerate_suffix(self.fd_mm)

        self.fd_h.close()
        self.fd_mm.close()

        self.generate_classes_registration()


#
#
# Generator for for C functions
#
#
class JSBGenerateFunctions(JSBGenerate):
    def __init__(self, config):
        super(JSBGenerateFunctions, self).__init__(config)
        self.functions_bound = []

    #
    # BEGIN helper functions
    #
    def create_files(self):
        self.fd_h = open('%s%s_functions.h' % (BINDINGS_PREFIX, self.namespace), 'w')
        self.generate_function_header_prefix()
        self.fd_mm = open('%s%s_functions.mm' % (BINDINGS_PREFIX, self.namespace), 'w')

    def get_function_property(self, func_name, property):
        try:
            return self.function_properties[func_name][property]
        except KeyError:
            return None

    def convert_function_name_to_js(self, function_name):
        name = self.get_function_property(function_name, 'name')
        if name != None:
            return name

        name = function_name
        if function_name.startswith(self.function_prefix):
            name = name[len(self.function_prefix):]
            name = name[0].lower() + name[1:]
        return name

    #
    # END helper functions
    #

    def generate_function_mm_prefix(self):
        import_template = '''
#%s "jsfriendapi.h"
#%s "jsb_config.h"
#%s "jsb_core.h"
#%s "jsb_basic_conversions.h"
#%s "%s%s_functions.h"
'''
        if self.compatible_with_cpp:
            import_name = 'include'
        else:
            import_name = 'import'

        self.generate_autogenerated_prefix(self.fd_mm)
        self.fd_mm.write(import_template % (import_name, import_name, import_name, import_name, import_name, BINDINGS_PREFIX, self.namespace))

    def generate_function_header_prefix(self):
        self.generate_autogenerated_prefix(self.fd_h)
        self.fd_h.write('''
#ifdef __cplusplus
extern "C" {
#endif
''')

    def generate_function_header_suffix(self):
        self.fd_h.write('''
#ifdef __cplusplus
}
#endif
''')
        self.generate_autogenerate_suffix(self.fd_h)

    def generate_function_declaration(self, func_name):
        # JSB_ccDrawPoint
        template_funcname = 'JSBool %s%s(JSContext *cx, uint32_t argc, jsval *vp);\n'
        self.fd_h.write(template_funcname % (PROXY_PREFIX, func_name))

    def generate_function_c_call_arg(self, i, dt):
        ret = ''
        # cast needed to prevent compiler errors
        if i > 0:
            ret += ', '
        ret += '(%s)arg%d ' % (dt, i)
        return ret

    def generate_function_c_call_name(self, name):
        # it could be overriden by plugins
        return name

    def generate_function_c_call(self, func_name, num_of_args, ret_js_type, args_declared_type):

        func_name = self.generate_function_c_call_name(func_name)
        if ret_js_type:
            prefix = '\tret_val = %s(' % func_name
        else:
            prefix = '\t%s(' % func_name

        call = ''

        for i, dt in enumerate(args_declared_type):
            call += self.generate_function_c_call_arg(i, dt)

        call += ' );'

        return '%s%s' % (prefix, call)

    def generate_function_prefix(self, func_name, num_of_args):
        # JSB_ccDrawPoint
        template_funcname = '''
JSBool %s%s(JSContext *cx, uint32_t argc, jsval *vp) {
'''
        self.fd_mm.write(template_funcname % (PROXY_PREFIX, func_name))

        # Number of arguments
        self.fd_mm.write('\tJSB_PRECONDITION2( argc == %d, cx, JS_FALSE, "Invalid number of arguments" );\n' % num_of_args)

    def generate_function_suffix(self):
        end_template = '''
\treturn JS_TRUE;
}
'''
        self.fd_mm.write(end_template)

    def generate_function_binding(self, function):
        func_name = function['name']

        # Don't generate functions that are defined as callbacks
        if func_name in self.callback_functions:
            raise ParseException('Function defined as callback. Ignoring %s' % func_name)

        args_js_type, args_declared_type = self.validate_arguments(function)
        ret_js_type, ret_declared_type = self.validate_retval(function)

        num_of_args = len(args_declared_type)

        # writes method description
        self.fd_mm.write('\n// Arguments: %s\n// Ret value: %s' % (', '.join(args_declared_type), ret_declared_type))

        self.generate_function_prefix(func_name, num_of_args)

        if len(args_js_type) > 0:
            self.generate_arguments(args_declared_type, args_js_type)

        if ret_js_type:
            ret_type = ret_declared_type
            if 'const' in function['retval'][0]:
                ret_type = 'const ' + ret_type
            self.fd_mm.write('\t%s ret_val;\n' % ret_type)

        call_real = self.generate_function_c_call(func_name, num_of_args, ret_js_type, args_declared_type)
        self.fd_mm.write('\n%s\n' % call_real)

        ret_string = self.generate_retval(ret_declared_type, ret_js_type)
        if not ret_string:
            raise ParseException('invalid return string')

        self.fd_mm.write(ret_string)

        self.generate_function_suffix()

        return True

    def generate_function_registration(self, func_name):
        function = None
        for func in self.bs['signatures']['function']:
            if func['name'] == func_name:
                function = func
                break

        num_args = self.get_number_of_arguments(function)
        js_func_name = self.convert_function_name_to_js(func_name)
        template = 'JS_DefineFunction(_cx, %s, "%s", %s, %d, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );\n' % \
                  (self.namespace,
                   js_func_name,
                   PROXY_PREFIX + func_name,
                   num_args)

        self.function_registration_file.write(template)

        # Add bound function to list of JS bound functions
        self.bound_js_functions.append('%s.%s' % (self.config.js_namespace, js_func_name))

    def generate_functions_registration(self):
        self.function_registration_file = open('%s%s_functions_registration.h' % (BINDINGS_PREFIX, self.namespace), 'w')
        self.generate_autogenerated_prefix(self.function_registration_file)

        for func in self.functions_bound:
            self.generate_function_registration(func)

        self.generate_autogenerate_suffix(self.function_registration_file)
        self.function_registration_file.close()

    #
    # main
    #
    def generate_bindings(self):
        '''Main entry point to generate the JS Bindings for the C functions'''

        self.create_files()

        self.generate_function_mm_prefix()

        functions = self.bs['signatures']['function']

        for f in functions:
            if f['name'] in self.functions_to_bind:
                try:
                    if f['name'] not in self.config.function_manual:
                        self.generate_function_binding(f)
                    self.generate_function_declaration(f['name'])
                    self.functions_bound.append(f['name'])
                except ParseException, e:
                    sys.stderr.write('NOT OK: "%s" Error: %s\n' % (f['name'], str(e)))

        self.generate_function_header_suffix()
        self.fd_h.close()

        self.generate_autogenerate_suffix(self.fd_mm)
        self.fd_mm.close()

        self.generate_functions_registration()


#
#
# Generates Object Oriented Code from C functions
#
#
class JSBGenerateOOFunctions(JSBGenerateFunctions):
    '''Class that generate Object Oriented JS Bindings after C API'''
    def __init__(self, config):
        super(JSBGenerateOOFunctions, self).__init__(config)

        # "methods" that were successfully bound to the "classes"
        self.bound_methods = {}

        # Yes, generating Object Oriented Functions
        self.generating_OOF = True

    #
    # BEGIN of Helper functions
    #
    def is_oof_method(self, klass_name, name):
        '''returns whether or not name is a method of klass_name'''

        # Member of the class ?
        if not name.startswith(klass_name):
            return False

        # constructor ?
        constructor_suffix = self.c_object_properties['constructor_suffix'].keys()[0]
        const_name = '%s%s' % (klass_name, constructor_suffix)
        # Hack for Chipmunk. Supports: "cpShapeBoxNew2"
        if name.startswith(const_name):
            return False

        # destructor ?
        destructor_suffix = self.c_object_properties['destructor_suffix'].keys()[0]
        if name == '%s%s' % (klass_name, destructor_suffix):
            return False

        # Only methods
        return True

    def is_manually_bound_oo_function(self, klass_name, func_name):
        '''returns whether or not the method is manually bound'''
        return (klass_name in self.manual_bound_methods) and (func_name in self.manual_bound_methods[klass_name])

    def create_files(self):
        self.fd_h = open('%s%s_auto_classes.h' % (BINDINGS_PREFIX, self.namespace), 'w')
        self.fd_mm = open('%s%s_auto_classes.mm' % (BINDINGS_PREFIX, self.namespace), 'w')
        self.fd_registration = open('%s%s_auto_classes_registration.h' % (BINDINGS_PREFIX, self.namespace), 'w')

    def get_base_class(self, klass_name):
        '''returns the base class of a given class name'''
        base_class = self.c_object_properties.get('base_class', {None: None})
        base_class = base_class.keys()[0]

        classes = self.c_object_properties['classes']
        for k in classes:
            if k == klass_name:
                if classes[k] == None:
                    return base_class
                return classes[k]

    def get_name_for_oof(self, klass_name, func):
        '''returns the JS function name, the native function name and the number of args'''
        name = func['name']
        js_name = name[len(klass_name):]
        js_name = uncapitalize(js_name)

        native_name = '%s%s_%s' % (PROXY_PREFIX, klass_name, js_name)

        args = self.get_number_of_arguments(func)
        args = max(0, args - 1)

        return js_name, native_name, args

    def sort_oo_classes(self):
        """returns a list of the OO function-classes to parse. Inheritance is taken into account. Base classes are returned first. Only supports 1 level of inheritance"""

        tree = {}
        l = []
        for k in self.c_object_properties['classes']:
            v = self.c_object_properties['classes'][k]

            if not v in tree:
                tree[v] = []
            tree[v].append(k)

        # Start for orphan
        # XXX Only supports one level of inheritance. Good enough for Chipmunk
        orphans = tree[None]
        for k in orphans:
            l.append(k)
            if k in tree:
                for kk in tree[k]:
                    l.append(kk)
        return l

    def get_oof_name(self, klass_name, func_name):
        '''returns an Object Oriented Function name after a function name'''
        func_name = func_name[len(klass_name):]
        func_name = uncapitalize(func_name)
        return '%s_%s' % (klass_name, func_name)
    #
    # END of Helper functions
    #

    def generate_function_prefix(self, func_name, num_of_args):
        super(JSBGenerateOOFunctions, self).generate_function_prefix(func_name, num_of_args)
        template = '''
\tJSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
\tstruct jsb_c_proxy_s *proxy = JSB_get_c_proxy_for_jsobject(jsthis);
\t%s* arg0 = (%s*) proxy->handle;
'''
        self.fd_mm.write(template % (self.current_class_name, self.current_class_name))

    def generate_implementation_prefix(self):
        '''Generates include files'''
        self.generate_function_mm_prefix()

    def generate_implementation_suffix(self):
        self.generate_autogenerate_suffix(self.fd_mm)

    def generate_implementation_class_variables(self, klass_name):
        template = '''
/*
 * %s
 */
#pragma mark - %s

JSClass* %s_class = NULL;
JSObject* %s_object = NULL;
'''
        name = '%s%s' % (PROXY_PREFIX, klass_name)
        self.fd_mm.write(template % (klass_name,
                                    klass_name,
                                    name,
                                    name))

    def generate_implementation_class_constructor(self, klass_name):
        template_0_pre = '''
// Constructor
JSBool %s_constructor(JSContext *cx, uint32_t argc, jsval *vp)
{
\tJSB_PRECONDITION2(argc==%d, cx, JS_FALSE, "Invalid number of arguments");
'''
        template_0_post = '''
\treturn JS_TRUE;
}
'''
        template_1_a = '\tJSObject *jsobj = JS_NewObject(cx, JSB_%s_class, JSB_%s_object, NULL);\n'
        template_1_b = '''
\n\tJSB_set_jsobject_for_proxy(jsobj, ret_val);
\tJSB_set_c_proxy_for_jsobject(jsobj, ret_val, JSB_C_FLAG_CALL_FREE);
\tJS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
'''

        constructor_suffix = self.c_object_properties['constructor_suffix'].keys()[0]
        name = '%s%s' % (PROXY_PREFIX, klass_name)
        func_name = '%s%s' % (klass_name, constructor_suffix)

        klass = klass_name
        while not func_name in self.functions_to_bind:
            klass = self.get_base_class(klass)
            sys.stderr.write('Warning: "Constructor" not found: %s. Using parent class: %s\n' % (func_name, klass))
            func_name = '%s%s' % (klass, constructor_suffix)
            if klass is None:
                break

        # Manually bound constructor ?
        if klass in self.manual_bound_methods and func_name in self.manual_bound_methods[klass]:
            sys.stderr.write("'Constructor': %s manually bound" % func_name)
            return

        num_of_args = 0
        try:
            if klass is not None:

                function = self.get_function(func_name)

                args_js_type, args_declared_type = self.validate_arguments(function)

                num_of_args = len(args_declared_type)

                # writes method description
                self.fd_mm.write('// Arguments: %s' % ', '.join(args_declared_type))
                self.fd_mm.write(template_0_pre % (name, num_of_args))
                self.fd_mm.write(template_1_a % (klass_name, klass_name))

                if num_of_args > 0:
                    self.generate_arguments(args_declared_type, args_js_type)

                call = self.generate_function_c_call(func_name, num_of_args, True, args_declared_type)
                self.fd_mm.write('\tvoid* %s' % call)

                self.fd_mm.write(template_1_b)

        except ParseException, e:
            self.fd_mm.write(template_0_pre % (name, num_of_args))
            self.fd_mm.write('\tJSB_PRECONDITION2(NO, cx, JS_TRUE, "Not possible to generate constructor: %s");\n' % str(e))

        if klass is None:
            self.fd_mm.write(template_0_pre % (name, num_of_args))
            self.fd_mm.write('\tJSB_PRECONDITION2(NO, cx, JS_TRUE, "No constructor");\n')

        self.fd_mm.write(template_0_post)

    def generate_implementation_class_destructor(self, klass_name):
        template = '''
// Destructor
void %s_finalize(JSFreeOp *fop, JSObject *jsthis)
{
\tstruct jsb_c_proxy_s *proxy = JSB_get_c_proxy_for_jsobject(jsthis);
\tif( proxy ) {
\t\tCCLOGINFO(@"jsbindings: finalizing JS object %%p (%s), handle: %%p", jsthis, proxy->handle);

\t\tJSB_del_jsobject_for_proxy(proxy->handle);
\t\tif(proxy->flags == JSB_C_FLAG_CALL_FREE)
\t\t\t%s( (%s*)proxy->handle);
\t\tJSB_del_c_proxy_for_jsobject(jsthis);
\t} else {
\t\tCCLOGINFO(@"jsbindings: finalizing uninitialized JS object %%p (%s)", jsthis);
\t}
}
'''
        destructor_suffix = self.c_object_properties['destructor_suffix'].keys()[0]
        name = '%s%s' % (PROXY_PREFIX, klass_name)
        func_name = '%s%s' % (klass_name, destructor_suffix)

        klass = klass_name
        while not func_name in self.functions_to_bind:
            klass = self.get_base_class(klass)
            sys.stderr.write('"Destructor" not found: %s. Using parent class: %s\n' % (func_name, klass))
            func_name = '%s%s' % (klass, destructor_suffix)
            if klass is None:
                break

        if klass == None:
            func_name = '// No destructor found: '

        # Manually bound constructor ?
        if klass in self.manual_bound_methods and func_name in self.manual_bound_methods[klass]:
            sys.stderr.write("'Destructor': %s manually bound" % func_name)
            return

        self.fd_mm.write(template % (name,
                                    klass_name,
                                    func_name, klass,
                                    klass_name
                                    ))

    def generate_implementation_class_method(self, klass_name, function):
        func_name = function['name']
        jsb_func_name = self.get_oof_name(klass_name, func_name)

        # Don't generate functions that are defined as callbacks
        if func_name in self.callback_functions:
            raise ParseException('Function defined as callback. Ignoring %s' % func_name)

        args_js_type, args_declared_type = self.validate_arguments(function)
        ret_js_type, ret_declared_type = self.validate_retval(function)

        num_of_args = len(args_declared_type)

        # writes method description. Skip first argument
        self.fd_mm.write('\n// Arguments: %s\n// Ret value: %s' % (', '.join(args_declared_type[1:]), ret_declared_type))

        self.generate_function_prefix(jsb_func_name, max(0, num_of_args - 1))

        # Skip first argument, since argv[0] should be "self"
        if len(args_js_type) > 1:
            self.generate_arguments(args_declared_type, args_js_type, {'first_arg': 1})

        if ret_js_type:
            self.fd_mm.write('\t%s ret_val;\n' % ret_declared_type)

        call_real = self.generate_function_c_call(func_name, num_of_args, ret_js_type, args_declared_type)
        self.fd_mm.write('\n%s\n' % call_real)

        ret_string = self.generate_retval(ret_declared_type, ret_js_type)
        if not ret_string:
            raise ParseException('invalid return string')

        self.fd_mm.write(ret_string)

        self.generate_function_suffix()

        return True

    def generate_implementation_class_methods(self, klass_name):
        '''Generates the bindings for all the "methods"'''

        self.bound_methods[klass_name] = []
        for func in self.bs['signatures']['function']:
            name = func['name']
            if name in self.functions_to_bind and self.is_oof_method(klass_name, name) and not self.is_manually_bound_oo_function(klass_name, name):
                # XXX: this works in chipmunk because the "classes" has the 'baseclass' at the end:
                #   cpCircleShape (OK)
                # But it won't work in this case:
                #   cpShapeCircle  (Won't work).
                # XXX: Script needs to be improved
                try:
                    self.generate_implementation_class_method(klass_name, func)
                    self.bound_methods[klass_name].append(func)
                except ParseException, e:
                    sys.stderr.write('NOT OK: "%s" Error: %s\n' % (name, str(e)))

    def generate_implementation_class_jsb(self, klass_name):
        template_0 = '''
void %s_createClass(JSContext *cx, JSObject* globalObj, const char* name )
{
\t%s_class = (JSClass *)calloc(1, sizeof(JSClass));
\t%s_class->name = name;
\t%s_class->addProperty = JS_PropertyStub;
\t%s_class->delProperty = JS_PropertyStub;
\t%s_class->getProperty = JS_PropertyStub;
\t%s_class->setProperty = JS_StrictPropertyStub;
\t%s_class->enumerate = JS_EnumerateStub;
\t%s_class->resolve = JS_ResolveStub;
\t%s_class->convert = JS_ConvertStub;
\t%s_class->finalize = %s_finalize;
\t%s_class->flags = JSCLASS_HAS_PRIVATE;
'''
        name = '%s%s' % (PROXY_PREFIX, klass_name)
        self.fd_mm.write(template_0 % (name,
                                        name,
                                        name,
                                        name,
                                        name,
                                        name,
                                        name,
                                        name,
                                        name,
                                        name,
                                        name, name,
                                        name))

        template_propertes = '''
\tstatic JSPropertySpec properties[] = {
\t\t{0, 0, 0, 0, 0}
\t};
'''
        self.fd_mm.write(template_propertes)

        template_funcs_pre = '\tstatic JSFunctionSpec funcs[] = {\n'
        template_funcs_body = '\t\tJS_FN("%s", %s, %d, JSPROP_PERMANENT | JSPROP_ENUMERATE),\n'
        template_funcs_post = '\t\tJS_FS_END\n\t};'

        self.fd_mm.write(template_funcs_pre)
        for f in self.bound_methods[klass_name]:
            js_fn_name, native_fn_name, args = self.get_name_for_oof(klass_name, f)
            self.fd_mm.write(template_funcs_body % (js_fn_name, native_fn_name, args))

        # Manually bound methods too
        if klass_name in self.manual_bound_methods:
            for func_name in self.manual_bound_methods[klass_name]:
                # skip constructors / destructors
                if self.is_oof_method(klass_name, func_name):
                    f = self.get_function(func_name)
                    js_fn_name, native_fn_name, args = self.get_name_for_oof(klass_name, f)
                    self.fd_mm.write(template_funcs_body % (js_fn_name, native_fn_name, args))

        # post template
        self.fd_mm.write(template_funcs_post)

        template_st_funcs = '''
\tstatic JSFunctionSpec st_funcs[] = {
\t\tJS_FS_END
\t};
'''
        self.fd_mm.write(template_st_funcs)

        template_end = '''
\t%s_object = JS_InitClass(cx, globalObj, %s, %s_class, %s_constructor,0,properties,funcs,NULL,st_funcs);
\tJSBool found;
\tJS_SetPropertyAttributes(cx, globalObj, name, JSPROP_ENUMERATE | JSPROP_READONLY, &found);
}
'''
        parent = self.get_base_class(klass_name)
        if parent == None:
            parent = 'NULL'
        else:
            parent = '%s%s_object' % (PROXY_PREFIX, parent)
        self.fd_mm.write(template_end % (name, parent, name, name))

    def generate_implementation_class(self, klass_name):
        self.generate_implementation_class_variables(klass_name)
        self.generate_implementation_class_constructor(klass_name)
        self.generate_implementation_class_destructor(klass_name)
        self.generate_implementation_class_methods(klass_name)
        self.generate_implementation_class_jsb(klass_name)

    def generate_implementation(self):
        self.generate_implementation_prefix()

        klasses = self.sort_oo_classes()
        for klass_name in klasses:
            self.current_class_name = klass_name
            self.generate_implementation_class(klass_name)

        self.generate_implementation_suffix()

    def generate_header(self):
        '''Generates the .h for the .mm file'''

        template = 'extern JSObject *JSB_%s_object;\nextern JSClass *JSB_%s_class;\nvoid JSB_%s_createClass(JSContext *cx, JSObject* globalObj, const char* name );\n'

        self.generate_autogenerated_prefix(self.fd_h)
        klasses = self.sort_oo_classes()
        for klass_name in klasses:
            self.fd_h.write(template % (klass_name, klass_name, klass_name))
        self.generate_autogenerate_suffix(self.fd_h)

    def generate_registration(self):
        '''Generates the code that will register the clases into the JS VM'''

        self.generate_autogenerated_prefix(self.fd_registration)
        klasses = self.sort_oo_classes()
        for klass_name in klasses:
            js_class_name = klass_name
            if klass_name.startswith(self.function_prefix):
                js_class_name = klass_name[len(self.function_prefix):]

            self.fd_registration.write('%s%s_createClass(_cx, %s, "%s");\n' % (PROXY_PREFIX, klass_name, self.namespace, js_class_name))
        self.generate_autogenerate_suffix(self.fd_registration)

    def generate_bindings(self):
        self.create_files()
        self.generate_implementation()
        self.generate_header()
        self.generate_registration()


#
#
# Generate Constants
#
#
class JSBGenerateConstants(JSBGenerate):

    def generate_autogenerated_prefix(self, fd):
        autogenerated_template = '''/*
* AUTOGENERATED FILE. DO NOT EDIT IT
* Generated by "%s -c %s" on %s
* Script version: %s
*/

var %s = %s || {};
'''
        fd.write(autogenerated_template % (os.path.basename(sys.argv[0]), os.path.basename(sys.argv[2]), datetime.date.today(), JSB_VERSION,
            self.config.js_namespace, self.config.js_namespace
            ))

    def create_files(self):
        self.fd_js = open('../js/jsb_%s_constants.js' % (self.namespace), 'w')

    def get_name_for_constant(self, name):
        prefix = self.get_constant_property('prefix_to_remove')
        if prefix and name.startswith(prefix):
            name = name[len(prefix):]

        # sanity check: variables can't start with digit in JS
        if name[0].isdigit():
            name = '_' + name

        return name

    def get_value_for_enum(self, value):
        ret = ''
        try:
            v = int(value)
            if v >= 0:
                ret = '0x%x' % v
            else:
                ret = value
        except ValueError:
            ret = value

        # Float with ending 'f' but not an hexadecimad
        if ret[-1] == 'f' and not ret.startswith('0x'):
            ret = ret[:-1]
        return ret

    def get_value_for_string_constant(self, value):
        return "'" + value + "'"

    def generate_bindings(self):
        '''Main entry point. Generates the JS bindings'''
        self.create_files()
        self.generate_autogenerated_prefix(self.fd_js)

        try:
            enums = self.bs['signatures']['enum']
            for e in enums:
                new_name = self.get_name_for_constant(e['name'])
                new_value = self.get_value_for_enum(e['value'])

                # only write to if if both are not none
                if new_name is not None and new_value is not None:
                    self.fd_js.write('%s.%s\t= %s;\n' % (self.config.js_namespace, new_name, new_value))
        except KeyError:
            pass

        try:
            string_constants = self.bs['signatures']['string_constant']
            for s in string_constants:
                new_name = self.get_name_for_constant(s['name'])
                new_value = self.get_value_for_string_constant(s['value'])

                # only write to if if both are not none
                if new_name is not None and new_value is not None:
                    self.fd_js.write('%s.%s\t= %s;\n' % (self.config.js_namespace, new_name, new_value))
        except KeyError:
            pass

        self.fd_js.close()


# Does nothing. Useful if you don't want to generate the enums
# Use it from the plugins
class JSBGenerateConstants_Ignore(JSBGenerateConstants):
    def generate_bindings(self):
        pass


#
#
# Main class for the Bindings
#
#
class JSBindings(object):

    @classmethod
    def parse_config_file(cls, config_file):
        cp = ConfigParser.ConfigParser()
        cp.read(config_file)

        supported_options = {'obj_class_prefix_to_remove': '',
                             'classes_to_parse': [],
                             'classes_to_ignore': [],
                             'class_properties': [],
                             'bridge_support_file': [],
                             'complement_file': [],
                             'inherit_class_methods': 'Auto',
                             'functions_to_parse': [],
                             'functions_to_ignore': [],
                             'function_properties': [],
                             'function_prefix_to_remove': '',
                             'method_properties': [],
                             'struct_properties': [],
                             'objects_from_c_functions': [],
                             'import_files': [],
                             'compatible_with_cpp': False,
                             'js_new_methods': [],
                             'constant_properties': [],
                             'js_namespace': '',
                             'plugin': [],
                             }

        for s in cp.sections():
            config = copy.copy(supported_options)

            # Section is the config namespace
            config['namespace'] = s

            for o in cp.options(s):
                if not o in config:
                    print 'Ignoring unrecognized option: %s' % o
                    continue

                t = type(config[o])
                if t == type(True):
                    v = cp.getboolean(s, o)
                elif t == type(1):
                    v = cp.getint(s, o)
                elif t == type(''):
                    v = cp.get(s, o)
                elif t == type([]):
                    v = cp.get(s, o)
                    v = v.replace('\t', '')
                    v = v.replace('\n', '')
                    v = v.replace(' ', '')
                    v = v.strip()
                    v = v.split(',')
                else:
                    raise Exception('Unsupported type' % str(t))
                config[o] = v

            config_path = os.path.dirname(config_file)
            sp = JSBindings(config, config_path)
            sp.generate_bindings()

    def __init__(self, config, config_path=''):

        self.config_path = config_path
        self.complement_files = config['complement_file']
        self.init_complement_file()

        self.bridgesupport_files = config['bridge_support_file']
        self.init_bridgesupport_file()

        self.namespace = config['namespace']
        self.js_namespace = config['js_namespace'] if 'js_namespace' in config and config['js_namespace'] else self.namespace

        #
        # All
        #
        self.import_files = config['import_files']
        self.compatible_with_cpp = config['compatible_with_cpp']

        #
        # Classes related
        #
        self.class_prefix = config['obj_class_prefix_to_remove']
        self._inherit_class_methods = config['inherit_class_methods']

        # Add here manually generated classes
        self.init_class_properties(config['class_properties'])
        self.init_classes_to_bind(config['classes_to_parse'])
        self.init_classes_to_ignore(config['classes_to_ignore'])

        # In order to prevent parsing a class many times
        self.parsed_classes = []

        #
        # Method related
        #
        self.init_method_properties(config['method_properties'])

        self.init_callback_methods()
        # Current method that is being parsed
        self.current_method = None

        #
        # function related
        #
        self.function_prefix = config['function_prefix_to_remove']
        self.init_functions_to_bind(config['functions_to_parse'])
        self.init_functions_to_ignore(config['functions_to_ignore'])
        self.init_function_properties(config['function_properties'])
        self.init_objects_from_c_functions(config['objects_from_c_functions'])
        self.current_function = None
        self.callback_functions = []

        #
        # struct related
        #
        self.init_struct_properties(config['struct_properties'])

        #
        # constant related
        #
        self.init_constant_properties(config['constant_properties'])

        #
        # JS methods related
        #
        self.init_js_new_methods(config['js_new_methods'])

        #
        # Plugin init
        #
        self.init_plugin(config['plugin'])

    def init_complement_file(self):
        self.complement = {}
        for f in self.complement_files:
            # empty string ??
            if f:
                fd = open(self.get_path_for(f))
                self.complement.update(ast.literal_eval(fd.read()))
                fd.close()

    def init_bridgesupport_file(self):
        self.bs = {}
        self.bs['signatures'] = {}

        for f in self.bridgesupport_files:
            p = ET.parse(self.get_path_for(f))
            root = p.getroot()
            xml = xml2d(root)
            for key in xml['signatures']:
                # More than 1 file can be loaded
                # So, older keys should not be overwritten
                if not key in self.bs['signatures']:
                    self.bs['signatures'][key] = xml['signatures'][key]
                else:
                    l = self.bs['signatures'][key]
                    if type(l) == type([]):
                        self.bs['signatures'][key].extend(xml['signatures'][key])

    def init_callback_methods(self):
        self.callback_methods = {}

        for class_name in self.method_properties:
            methods = self.method_properties[class_name]
            for method in methods:
                if 'callback' in self.method_properties[class_name][method]:
                    if not class_name in self.callback_methods:
                        self.callback_methods[class_name] = []
                    self.callback_methods[class_name].append(method)

    def process_method_properties(self, klass, method_name, props):

        if not klass in self.method_properties:
            self.method_properties[klass] = {}
        if not method_name in self.method_properties[klass]:
            self.method_properties[klass][method_name] = {}
        self.method_properties[klass][method_name] = copy.copy(props)

        # Process "merge"
        if 'merge' in props:
            lm = props['merge'].split('|')

            # append self
            lm.append(method_name)

            methods = {}
            # needed to obtain the selector with greater number of args
            max_args = 0
            # needed for optional_args_since
            min_args = 1000

            for m in lm:
                m = m.strip()
                args = m.count(':')
                methods[args] = m
                if args > max_args:
                    max_args = args
                if args < min_args:
                    min_args = args

                # Automatically add "ignore" in the method_properties, but not in "self"
                if m != method_name:
                    self.set_method_property(klass, m, 'ignore', True)

            # Add max/min/calls rules
            self.set_method_property(klass, method_name, 'calls', methods)
            self.set_method_property(klass, method_name, 'min_args', min_args)
            self.set_method_property(klass, method_name, 'max_args', max_args)

            # safety check
            if method_name.count(':') != max_args:
                raise Exception("Merge methods should have less arguments that the main method. Check: %s # %s" % (klass, method_name))

        if 'name' in props:
            # If this name was previously used, the delete it. Only the newer one will be used
            # this scenario can happen when defining a name using a regexp, and then change it with a single line
            name = props['name']
            for m in self.method_properties[klass]:
                d = self.method_properties[klass][m]
                old_name = d.get('name', None)
                if m != method_name and old_name == name:
                    del(d['name'])
                    print 'Deleted duplicated from %s (old:%s)  (new:%s)' % (klass, m, method_name)

        if 'manual' in props:
            if not klass in self.manual_methods:
                self.manual_methods[klass] = []
            self.manual_methods[klass].append(method_name)

    def init_method_properties(self, properties):
        self.method_properties = {}
        self.manual_methods = {}
        for prop in properties:
            # key value
            try:
                if not prop or len(prop) == 0:
                    continue
                key, value = prop.split('=')

                # From Key get: Class # method
                klass, method = key.split('#')
                klass = klass.strip()
                method = method.strip()

                opts = {}
                # From value get options
                options = value.split(';')
                for o in options:
                    # Options can have their own Key Value
                    if ':' in o:
                        o = o.replace('"', '')
                        o = o.replace("'", "")

                        # o_value might also have some ':'
                        # So, it should split by the first ':'
                        o_list = o.split(':')
                        o_key = o_list[0]
                        o_val = ':'.join(o_list[1:])
                    else:
                        o_key = o
                        o_val = True
                    opts[o_key] = o_val

                expanded_klasses = self.expand_regexp_names([klass], self.supported_classes)
                for k in expanded_klasses:
                    self.process_method_properties(k, method, opts)
            except ValueError:
                sys.stderr.write("\nERROR parsing line: %s\n\n" % (prop))
                raise

    def init_function_properties(self, properties):
        self.function_properties = {}
        self.function_manual = []
        for prop in properties:
            # key value
            if not prop or len(prop) == 0:
                continue
            key, value = prop.split('=')

            opts = {}
            # From value get options
            options = value.split(';')
            for o in options:
                # Options can have their own Key Value
                if ':' in o:
                    o_key, o_val = o.split(':')
                    o_val = o_val.replace('"', '')    # remove possible "
                else:
                    o_key = o
                    o_val = None
                opts[o_key] = o_val

                if o_key == 'manual':
                    self.function_manual.append(key)
            self.function_properties[key] = opts

    def init_struct_properties(self, properties):
        self.struct_properties = {}
        self.struct_opaque = []
        self.struct_manual = []
        for prop in properties:
            # key value
            if not prop or len(prop) == 0:
                continue
            key, value = prop.split('=')

            opts = {}
            # From value get options
            options = value.split(';')
            for o in options:
                # Options can have their own Key Value
                if ':' in o:
                    o_key, o_val = o.split(':')
                    o_val = o_val.replace('"', '')    # remove possible "
                else:
                    o_key = o
                    o_val = None
                opts[o_key] = o_val

                # populate lists. easier to code
                if o_key == 'opaque':
                    # '*' is needed for opaque structs
                    self.struct_opaque.append(key + '*')
                elif o_key == 'manual':
                    self.struct_manual.append(key)
            self.struct_properties[key] = opts

    def init_constant_properties(self, properties):
        self.constant_properties = {}
        for prop in properties:
            # key value
            if not prop or len(prop) == 0:
                continue
            key, value = prop.split('=')
            self.constant_properties[key] = value

    def init_plugin(self, properties):
        self.plugin_properties = {}
        for prop in properties:
            # key value
            if not prop or len(prop) == 0:
                continue
            key, value = prop.split('=')
            self.plugin_properties[key] = value

    def init_js_new_methods(self, properties):
        self.js_new_methods = {}
        for prop in properties:
            if not prop or len(prop) == 0:
                continue
            key, value = prop.split('=')

            opts = {}
            # From value get options
            options = value.split(';')
            for o in options:
                # Options can have their own Key Value
                if ':' in o:
                    o_key, o_val = o.split(':')
                    o_val = o_val.replace('"', '')    # remove possible "
                    o_val = int(o_val)
                else:
                    o_key = o
                    o_val = None
                opts[o_key] = o_val

            self.js_new_methods[key] = opts

    def init_functions_to_bind(self, functions):
        self._functions_to_bind = set(functions)
        ref_list = []

        if 'function' in self.bs['signatures']:
            for k in self.bs['signatures']['function']:
                ref_list.append(k['name'])
            self.functions_to_bind = self.expand_regexp_names(self._functions_to_bind, ref_list)
        else:
            self.functions_to_bind = []

    def init_functions_to_ignore(self, klasses):
        self._functions_to_ignore = klasses
        self.functions_to_ignore = self.expand_regexp_names(self._functions_to_ignore, self.functions_to_bind)

        copy_set = copy.copy(self.functions_to_bind)
        for i in self.functions_to_bind:
            if i in self.functions_to_ignore:
                print 'Explicitly removing %s from bindings...' % i
                copy_set.remove(i)

        self.functions_to_bind = copy_set

    def init_objects_from_c_functions(self, properties):
        self.c_object_properties = {}
        for prop in properties:
            # key value
            if not prop or len(prop) == 0:
                continue
            key, value = prop.split('=')

            opts = {}
            # From value get options
            options = value.split(';')
            for o in options:
                # Options can have their own Key Value
                if ':' in o:
                    o_key, o_val = o.split(':')
                    o_val = o_val.replace('"', '')    # remove possible "
                else:
                    o_key = o
                    o_val = None
                opts[o_key] = o_val
            self.c_object_properties[key] = opts

        # "Classes"
        self.function_classes = []
        d = self.c_object_properties.get('classes', [])
        for k in d:
            self.function_classes.append(k + '*')

        # Manual bound "methods"
        self.manual_bound_methods = {}
        d = self.c_object_properties.get('manual_bound_methods', [])
        for k in d:
            class_name = ''
            found = False
            for klass in self.function_classes:
                # remove the '*' from the class
                class_name = klass[:-1]
                if k.startswith(class_name):
                    found = True
                    break

            if not found:
                raise Exception("Error generating manual bound method: %s" % k)
            if not class_name in self.manual_bound_methods:
                self.manual_bound_methods[class_name] = []
            self.manual_bound_methods[class_name].append(k)

    def init_class_properties(self, properties):
        ref_list = []
        if 'class' in self.bs['signatures']:
            for k in self.bs['signatures']['class']:
                ref_list.append(k['name'])

        self.supported_classes = set()
        self.class_manual = []
        self.class_properties = {}
        for prop in properties:
            # key value
            if not prop or len(prop) == 0:
                continue
            klass_name, value = prop.split('=')

            # expand regular expression of class name
            keys = self.expand_regexp_names([klass_name], ref_list)

            # Hack to support "manual" classes here since they are not part of the classes to parse yet
            if keys == []:
                keys = [klass_name]

            for key in keys:
                opts = {}
                # From value get options
                options = value.split(';')
                for o in options:
                    # Options can have their own Key Value
                    if ':' in o:
                        o_key, o_val = o.split(':')
                        o_val = o_val.replace('"', '')    # remove possible "
                    else:
                        o_key = o
                        o_val = None
                    opts[o_key] = o_val

                    # populate lists. easier to code
                    if o_key == 'manual':
                        # '*' is needed for opaque structs
                        self.supported_classes.add(key)
                        self.class_manual.append(key)
                    elif o_key == 'ignore':
                        self.class_manual.append(key)

                self.class_properties[key] = opts

    def init_classes_to_bind(self, klasses):
        self._classes_to_bind = set(klasses)
        ref_list = []
        if 'class' in self.bs['signatures']:
            for k in self.bs['signatures']['class']:
                ref_list.append(k['name'])
        self.classes_to_bind = self.expand_regexp_names(self._classes_to_bind, ref_list)
        l = self.ancestors_of_classes_to_bind()
        s = set(self.classes_to_bind)
        self.classes_to_bind = s.union(set(l))

    def init_classes_to_ignore(self, klasses):
        self._classes_to_ignore = klasses
        self.classes_to_ignore = self.expand_regexp_names(self._classes_to_ignore, self.classes_to_bind)

        copy_set = copy.copy(self.classes_to_bind)
        for i in self.classes_to_bind:
            if i in self.classes_to_ignore:
                print 'Explicitly removing %s from bindings...' % i
                copy_set.remove(i)

        self.classes_to_bind = copy_set
        self.supported_classes = self.supported_classes.union(copy_set)

    # appends the config path, unless path is absolute
    def get_path_for(self, path):
        if not os.path.isabs(path):
            return os.path.join(self.config_path, path)
        return path

    def set_method_property(self, class_name, method_name, prop, value=True):

        if not class_name in self.method_properties:
            self.method_properties[class_name] = {}

        if not method_name in self.method_properties[class_name]:
            self.method_properties[class_name][method_name] = {}

        k = self.method_properties[class_name][method_name]
        k[prop] = value

    def ancestors_of_classes_to_bind(self):
        ancestors = []
        for klass in self.classes_to_bind:
            new_list = self.ancestors(klass, [klass])
            ancestors.extend(new_list)
        return ancestors

    def ancestors(self, klass, list_of_ancestors):
        if klass not in self.complement:
            return list_of_ancestors

        info = self.complement[klass]
        subclass = info['subclass']
        if not subclass:
            return list_of_ancestors

        list_of_ancestors.append(subclass)

        return self.ancestors(subclass, list_of_ancestors)

    def expand_regexp_names(self, names_to_expand, list_of_names):
        valid = []
        for n in list_of_names:
            for regexp in names_to_expand:
                if not regexp or regexp == '':
                    continue
                # if last char is not a regexp modifier,
                # then append '$' to regexp
                last_char = regexp[-1]
                if last_char in string.letters or last_char in string.digits or last_char == '_':
                    result = re.match(regexp + '$', n)
                else:
                    result = re.match(regexp, n)
                if result:
                    valid.append(n)

        ret = list(set(valid))
        return ret

    def generate_bindings(self):
        #
        # Classes
        #
        # is there any class to register
        if 'class' in self.bs['signatures']:
            if 'objc_class' in self.plugin_properties:
                klass = get_class(self.plugin_properties['objc_class'])
                classes = klass(self)
            else:
                classes = JSBGenerateClasses(self)
            classes.generate_bindings()

        #
        # Free Functions
        #
        # Is there any function to register:
        if 'function' in self.bs['signatures']:
            if 'function_class' in self.plugin_properties:
                klass = get_class(self.plugin_properties['function_class'])
                functions = klass(self)
            else:
                functions = JSBGenerateFunctions(self)
            functions.generate_bindings()
            functions.generate_externs()

        #
        # Object Oriented C code
        #
        if len(self.c_object_properties) > 0:
            if 'oo_function_class' in self.plugin_properties:
                klass = get_class(self.plugin_properties['oo_function_class'])
                oo_functions = klass(self)
            else:
                oo_functions = JSBGenerateOOFunctions(self)
            oo_functions.generate_bindings()

        #
        # Enums
        #
        if 'enum' in self.bs['signatures'] or 'string_constant' in self.bs['signatures']:
            if 'constant_class' in self.plugin_properties:
                klass = get_class(self.plugin_properties['constant_class'])
                enums = klass(self)
            else:
                enums = JSBGenerateConstants(self)
            enums.generate_bindings()


def help():
    print "%s %s - Script that generates glue code between C / Objective-C and JavaScript" % (sys.argv[0], JSB_VERSION)
    print "Usage:"
    print "\t-c --config-file\tConfiguration file needed to generate the glue code."
    print "\nExample:"
    print "\t%s -c cocos2d-jsb.ini" % sys.argv[0]
    sys.exit(-1)

if __name__ == "__main__":
    if len(sys.argv) == 1:
        help()

    configfile = None

    argv = sys.argv[1:]
    try:
        opts, args = getopt.getopt(argv, "c:", ["config-file="])

        for opt, arg in opts:
            if opt in ("-c", "--config-file"):
                configfile = arg
    except getopt.GetoptError, e:
        print e
        opts, args = getopt.getopt(argv, "", [])

    if args == None or configfile == None:
        help()

    JSBindings.parse_config_file(configfile)
