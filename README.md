# XFBlockDelegate

## Purpose

This is a simple class that allows you to quickly create delegate implementations using blocks. This can improve readability for delegates that only require short implementations and it also allows you to capture the scope of the class you're currently in.

It might not be useful for larger delegates that have to implement a lot of functionality, like UITableViewDelegates or NSURLConnectionDelegates, as it could quickly pollute the enclosing class.

## Installation

CocoaPods support coming soon!

## Usage

Instantiate an XFBlockDelegate through the class method, then simply add the Methods you want to implement:

``` objc
//Create a delegate using the specified Protocol
XFBlockDelegate *myDelegate = [XFBlockDelegate delegateWithProtocol:@protocol(MyObjectDelegate)];

//The subscripting syntax will simply convert the NSString to a selector
myDelegate[@"myObject:didDoSomethingWithResult:"] = ^(MyObject *obj, NSInteger result) {
    NSLog(@"%i", result);
};

//Alternatively, you can use this more verbose syntax
[myDelegate implementSelector:@selector(myObject:shouldAcceptNumber:) withBlock:^(MyObject *obj, NSNumber *number){
    return YES;
}];
    
//Finally, set the delegate at the end. Please note that you should always declare all the methods before setting the delegate on your object!
myObject.delegate = (id)myDelegate;
```

And that's it! XFBlockDelegate does a few runtime checks to ensure correct behaviour. For example, it throws an exception if you try to add a selector that isn't declared on the Protocol, or if the signature of the Block and the Method you are trying to implement don't match. It was designed this way to catch as many errors (typos, etc.) as soon as possible!

## Thanks

This code makes use of a modified version of [CTObjectiveCRuntimeAdditions](https://github.com/ebf/CTObjectiveCRuntimeAdditions) to check if a Block is compatible to a Method.

## License

MIT
