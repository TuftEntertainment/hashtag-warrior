//
//  HeroContactListener.h
//  hashtag-warrior
//
//  Created by Nick James on 18/02/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

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
    inline std::vector<Collision> const GetCollisions() const { return _collisions; };
    
private:
    // A vector of collisions.
    std::vector<Collision> _collisions;
    
    // Prevent.
    HeroContactListener(const HeroContactListener& rhs);
    HeroContactListener& operator=(const HeroContactListener& rhs);
};

#endif
