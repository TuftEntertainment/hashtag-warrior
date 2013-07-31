/*
 * #Warrior - http://tuftentertainment.github.io/hashtag-warrior/
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Tuft Entertainment
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

#ifndef hashtag_warrior_HeroContactListener_h
#define hashtag_warrior_HeroContactListener_h

#import "Box2D.h"
#import <vector>
#import <algorithm>

struct Collision
{
    // The two fixtures which collided.
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    
    // Override the == comparator.
    bool operator==(const Collision& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};

/**
 * A contact listener to detect collisions between our hero and a ball.
 *
 * Note: We cannot alter the physics within the contact listener.
 */
class HeroContactListener : public b2ContactListener
{        
public:
    HeroContactListener();
    ~HeroContactListener();
    
    // Virtual functions.
    virtual void BeginContact(b2Contact* contact);
    virtual void EndContact(b2Contact* contact);
    virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
    virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
    
    /**
     * Accessor to the collisions.
     *
     * @return The vector of collisions.
     */
    inline std::vector<Collision>* const GetCollisions() const { return _collisions; };
    
private:
    // A vector of collisions.
    std::vector<Collision>* _collisions;
    
    // Prevent.
    HeroContactListener(const HeroContactListener& rhs);
    HeroContactListener& operator=(const HeroContactListener& rhs);
};

#endif
