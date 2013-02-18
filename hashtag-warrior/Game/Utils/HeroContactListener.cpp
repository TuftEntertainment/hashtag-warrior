//
//  HeroContactListener.cpp
//  hashtag-warrior
//
//  Created by Nick James on 18/02/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#include "HeroContactListener.h"

HeroContactListener::HeroContactListener()
: _collisions()
{
}

HeroContactListener::~HeroContactListener()
{
}

void HeroContactListener::BeginContact(
    b2Contact* contact)
{
    // We need to copy out the data because the b2Contact passed in
    // is reused.
    Collision collision = { contact->GetFixtureA(), contact->GetFixtureB() };
    _collisions.push_back(collision);
}

void HeroContactListener::EndContact(
    b2Contact* contact)
{
    Collision collision = { contact->GetFixtureA(), contact->GetFixtureB() };
    
    std::vector<Collision>::iterator pos;
    pos = std::find(_collisions.begin(), _collisions.end(), collision);
    if (pos != _collisions.end())
    {
        _collisions.erase(pos);
    }
}

void HeroContactListener::PreSolve(
    b2Contact* contact, 
    const b2Manifold* oldManifold)
{
}

void HeroContactListener::PostSolve(
    b2Contact* contact,
    const b2ContactImpulse* impulse)
{
}
