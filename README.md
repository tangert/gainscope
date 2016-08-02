# gainscope

This is officially the first original iOS app I have built. It is a fitness-specialized map search that finds all the nearest coffee shops, gyms, and restaurants around you. It includes special pins for popular places like Starbucks, Dunkin Donuts, Crossfit gyms, the Y, Chipotle, etc.

Main APIs used:
- Yelp
- Uber (currently working)

#Cocoapods:
#Networking
- pod 'AFNetworking', '~> 2.5': HTTP networking 
- pod 'BDBOAuth1Manager': OAuth manager

#Data
- pod 'AsyncSwift': pretty GCD usage.
- pod 'Kingfisher', '~> 2.4': asynchronous image caching

#UIstuff
- pod 'Cosmos', '~> 1.2': star ratings in custom tableview cell
- pod 'SnapKit', '~> 0.15.0': programmatic autolayout constraints
