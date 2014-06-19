# Cache Flow

### To Do Before Publishing
* Make all the current constants configurable (I like how business_time does it)
* Add thorough tests
* Add usage guide
* Add background
* Install it in thredUP's web app to ensure the gem works as intended


### Rails Caching Background
When working with [caching in Rails](http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html), there are two common cache busting techniques. One is to use a cache key that busts itself. Example:
`Rails.cache.fetch("item-path-#{self.id}-#{Date.today.to_s}") { UrlBuilder.new(self).build }`

The cache key generated looks like this: `"item-path-959595-2014-06-18"`. In this example, the first time you call `Rails.cache.fetch`, it will store the returned value from `UrlBuilder.new(self).build`  in your cache store and it will be accessible using the cache key you provided. For subsequent `Rails.cache.fetch` calls, it will first look in cache (before executing the code in the block) to see if there's a value for the cache key and if so, it will return the value from memcached (or whatever your cache store is). This is the essence of caching - getting the same value without having to execute the code every time. If the code you're executing is costly (ex: pulling from the database), caching can yield great performance gains.

So what's wrong with this approach? When the server's time moves to the next day and this code runs, it will look in the cache store for a value with the key `item-path-959595-2014-06-19` and will find nothing. In this case, the code runs again and the value is stored for another day.

But what if we used that caching technique everywhere? A lot of code would be running when the server's time moves to the next day. That means the servers would be working extra at that time of the day. It might mean that your database server sees a CPU spike at that time...
![screenshot 2014-06-17 17 48 43](https://cloud.githubusercontent.com/assets/341055/3309720/f2ee7db2-f6a3-11e3-99db-463cca44d553.png)

Today, our website went down at 5:00pm (0:00 UTC server time). While we haven't scoured the DB logs at that exact minute, there are good odds that the DB outage was a result of busted cache keys + a heavy load on shop (400+ visitors at the time of crash). 400 people fetching fresh data throughout our system at the same time = :boom:

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

![http://blackathlete.net/wp-content/uploads/2013/12/cash.gif](http://blackathlete.net/wp-content/uploads/2013/12/cash.gif)

### Straight Cache Homey
Straight Cache Homey is my quick and fun way to address this issue. It returns to you a random expiry time that falls between a defined time range you want cache to expire. For us, that's 1-4am PST when the server's load is really light. Ideally, cache keys will bust randomly throughout this time and the large DB CPU spikes in the screenshot above will be distributed evenly throughout that time.
