//
//  OCCatch.h
//
//

#ifndef OCCatch_h
#define OCCatch_h

// add the code below to your -Bridging-Header.h

/**
 #import "OCCatch.h"
 */

//   How to use it in Swift?
/**
 let exception = tryBlock {
        let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
        //......
    }
  if let exception = exception {
    print("exception: \(exception)")
  }
*/

#import <Foundation/Foundation.h>

NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}

#endif /* OCCatch_h */
