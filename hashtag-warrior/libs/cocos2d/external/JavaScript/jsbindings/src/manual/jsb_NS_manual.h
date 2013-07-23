/*
 * JS Bindings: https://github.com/zynga/jsbindings
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef __JSB_NS_MANUAL_H
#define __JSB_NS_MANUAL_H

#import "jsb_config.h"

#ifdef JSB_INCLUDE_NS

#import "jsb_core.h"
#import "jsb_basic_conversions.h"

@interface JSB_NSObject : NSObject
{
	JSObject	*_jsObj;
	id			_realObj;
	Class		_klass;
	char		*_description;
}

@property (nonatomic, readwrite, assign) JSObject *jsObj;
@property (nonatomic, readwrite, assign) id	realObj;
@property (nonatomic, readonly) Class klass;

+(void) swizzleMethods;
+(JSObject*) createJSObjectWithRealObject:(id)realObj context:(JSContext*)JSContext;
-(id) initWithJSObject:(JSObject*)object class:(Class)klass;
-(void) unrootJSObject;
@end



#ifdef __cplusplus
extern "C" {
#endif
	
void JSB_NSObject_createClass(JSContext* cx, JSObject* globalObj, const char * name );
extern JSObject* JSB_NSObject_object;
extern JSClass* JSB_NSObject_class;

#ifdef __cplusplus
}
#endif



#ifdef __CC_PLATFORM_MAC

@interface JSB_NSEvent : JSB_NSObject
{
}
@end

#ifdef __cplusplus
extern "C" {
#endif
	void JSB_NSEvent_createClass(JSContext* cx, JSObject* globalObj, const char * name );
	extern JSObject* JSB_NSEvent_object;
	extern JSClass* JSB_NSEvent_class;
	
#ifdef __cplusplus
}
#endif

#elif defined(__CC_PLATFORM_IOS)

@interface JSB_UITouch : JSB_NSObject
{
}
@end

#ifdef __cplusplus
extern "C" {
#endif
	void JSB_UITouch_createClass(JSContext* cx, JSObject* globalObj, const char * name );
	extern JSObject* JSB_UITouch_object;
	extern JSClass* JSB_UITouch_class;
	
#ifdef __cplusplus
}
#endif


@interface JSB_UIAccelerometer : JSB_NSObject
{
}
@end

#ifdef __cplusplus
extern "C" {
#endif
	void JSB_UIAccelerometer_createClass(JSContext* cx, JSObject* globalObj, const char * name );
	extern JSObject* JSB_UIAccelerometer_object;
	extern JSClass* JSB_UIAccelerometer_class;
	
#ifdef __cplusplus
}
#endif

#endif // __CC_PLATFORM_IOS

#endif // JSB_INCLUDE_NS

#endif // __JSB_NS_MANUAL_H
