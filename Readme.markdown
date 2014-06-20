# Cache Flow

### To Do Before Publishing
* Make all the current constants configurable (I like how business_time does it)
* Add thorough tests
* Install it in thredUP's web app to ensure the gem works as intended

### What is Cache Flow?
Cache Flow is a gem that helps you distribute when your cache expires over a defined period of time. The problem this attempts to solve is detailed below, but in essence this gives you the ability to bust your cache randomly so that your cache doesn't bust all at the same time (ex: using the current day as the cache key) resulting in large DB CPU spikes (like in the screenshot below).

### Usage
* Install the gem

```shell
gem install cache-flow
```

* Open up your console

```ruby
# If in irb, you'll need to do the following
require 'cache-flow'

# Try the following
CacheFlow.new.generate_expiry

# In action
Rails.cache("count_of_never_nudes_in_world", expires_in: CacheFlow.new.generate_expiry) do
  "Dozens!"
end
```

The `expires_in` option accepts a number that is seconds from now that the cache should expire. For us, we chose 1-4am PST for the defined range of when we want our cache to expire since our server's traffic load is light during that window of time.

### Background - Straight Cache Homey
To understand the problem CacheFlow is solving, it's helpful to under [how caching works in Rails](http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html). There are two common cache busting techniques for the Rails cache store. The first is to use a dynamic cache key that busts itself. Example:
`Rails.cache.fetch("item-path-#{self.id}-#{Date.today.to_s}") { UrlBuilder.new(self).build }`

The cache key generated looks like this: `"item-path-959595-2014-06-18"`. In this example, the first time you call `Rails.cache.fetch`, it will store the returned value from `UrlBuilder.new(self).build`  in your cache store and it will be accessible using the cache key you provided. For subsequent `Rails.cache.fetch` calls, it will first look in cache (before executing the code in the block) to see if there's a value for the cache key and if so, it will return the value from memcached (or whatever your cache store is) without executing the code within the block you provide to `Rails.cache.fetch`. This is the essence of caching - getting the same value without having to execute the code every time. If the code you're executing is costly (ex: pulling from the database), caching can yield great performance gains.

So when the cache key is `"item-path-#{self.id}-#{Date.today.to_s}"`, the cache will expire when the server's clock moves to the next day. Rails will look for a value with the key `item-path-959595-2014-06-19` in your cache store and will find nothing. In this case, the code runs again and the value is stored for another day.

What's wrong with this technique? Well, possibly nothing, but if that caching technique is used everywhere, a lot of cache will be busting at the exact moment a new day starts on the server. Since our server runs in UTC, a lot of our cache was busting at 5pm (or 4pm depending on daylight savings time). This meant our servers were working extra hard at that time of the day. Our database server, in particular, saw a massive CPU spike at that time every day.
![screenshot 2014-06-17 17 48 43](https://cloud.githubusercontent.com/assets/341055/3309720/f2ee7db2-f6a3-11e3-99db-463cca44d553.png)

So...how about that other cache busting technique? It's the `:expires_in` option you can pass into `Rails.cache.fetch`. It works like this:

```ruby
def buster_bluth
  puts "I'm a monster!"
  "Hey Brother"
end

# 3.minutes = 180
Rails.cache.fetch("any_unique_key", expires_in: 3.minutes) { buster_bluth }
# Output after running:
# I'm a monster!
# => "Hey Brother"

# Wait 10 seconds
Rails.cache.fetch("any_unique_key", expires_in: 3.minutes) { buster_bluth }
# Output after running again:
# => "Hey Brother"

# wait 3 minutes
Rails.cache.fetch("any_unique_key", expires_in: 3.minutes) { buster_bluth }
# Output after running:
# I'm a monster!
# => "Hey Brother"
```
This is why CacheFlow was created. We wanted to utilize `expires_in` functionality to manage when our cache busts in a predictable way. With CacheFlow, you don't have to worry about when your cache store will bust - you just let CacheFlow take care of that. Straight cache, homey.

![http://blackathlete.net/wp-content/uploads/2013/12/cash.gif](http://blackathlete.net/wp-content/uploads/2013/12/cash.gif)
