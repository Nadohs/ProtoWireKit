//
//  PWKDispatcher.m
//  ProtoWireKit
//
//  Created by Richard Fox on 1/5/22.
//

#import "PWKDispatcher.h"
@interface PWKListWrapper: NSObject
@property (nonatomic, weak, readonly) id target;
-(id)initWithWeakItem:(id)target;
@end

@implementation PWKListWrapper

-(id)initWithWeakItem:(id)target{
    if (self = [super init]) {
        _target = target;
    }
    return self;
}
@end

@interface PWKDispatcher()
@property (nonatomic) NSMutableArray<PWKListWrapper *> *targets;
@end

@implementation PWKDispatcher

- (instancetype)init {
    if (self = [super init]) {
        self.targets = [NSMutableArray new];
    }
    return self;
}

-(id)targetReciever {
    return self;
}


-(NSArray<NSObject *> *)targets {
    return [_targets copy];
}

-(void)addListener:(NSObject *)target {
    for (PWKListWrapper *wrapper in self.targets) {
        //clean-up targets which were released from memory.
        if (wrapper.target == nil) {
            [_targets removeObject:wrapper];
        }
        if (wrapper.target == target) {
            return;
        }
    }
    PWKListWrapper *wrapped = [[PWKListWrapper alloc] initWithWeakItem:target];
    [_targets addObject:wrapped];
}

- (void)removeListener:(NSObject *)target {
    for (PWKListWrapper *wrapper in self.targets) {
        //clean-up targets which were released from memory.
        if (wrapper.target == nil) {
            [_targets removeObject:wrapper];
        }
        if (wrapper.target == target) {
            [_targets removeObject:wrapper];
            return;
        }
    }
}

-(BOOL)respondsToSelector:(SEL)aSelector {
    for (PWKListWrapper *item in self.targets) {
        if ([item.target respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    for (PWKListWrapper *item in self.targets) {
        id result = [item.target methodSignatureForSelector:sel];
        if (result) {
            return result;
        }
    }
    return nil;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    for (PWKListWrapper *item in self.targets) {
        if ([item.target respondsToSelector:anInvocation.selector])
        {
            // cannot call copy on `anInvocation` or crash time!
            [anInvocation invokeWithTarget:item.target];
        }
    }
}


@end
