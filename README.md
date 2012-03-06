# AEURLDownload #
## Block-based asynchronous URL downloading ##

`AEURLDownload` makes it easy to asynchronously download a URL to the 
filesystem, just like the `NSURLDownload` class that is available in desktop 
Cocoa. Even better, it uses blocks and chooses a safe, temporary location 
automatically.

* Start a download by calling `+downloadWithRequest:completionHandler:`
* When the download completes your completion handler block is called
  **on the main thread**. 
* The downloaded file is passed to you as an `NSURL` that is valid **only for
  the duration of the completion handler's execution.** You must copy it to a 
  new location if you want to hold onto it.
* Cancel an in-progress download by calling `-cancel` on the object that is
  returned from `+downloadWithRequest:completionHandler:`. You can safely 
  ignore that object if you don't want cancellation; you don't need to retain
  it until the download finishes.

## Why not NSURLConnectionDownloadDelegate? ##

`NSURLConnectionDownloadDelegate` would be perfect 
[if it worked](http://adamernst.com/post/18867872976/nsurlconnectiondownloaddelegate-doesnt-work).
It's only available for Newsstand apps as of this writing.

## How do I use it? ##

    [AEURLDownload downloadWithRequest:request 
                     completionHandler:^(NSURL *destinationURL, NSError *error) {
        // Handle the downloaded file or error.
    }];
