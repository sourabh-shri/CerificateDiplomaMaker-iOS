//
//  AutoLoaderImageView.m
//  MiEd
//
//  Created by Venus on 8/24/14.
//  Copyright (c) 2014 jupiter. All rights reserved.
//

#import "AutoLoaderImageView.h"
#import "Context.h"

@interface AutoLoaderImageView ()
@property (nonatomic, strong) NSString * currentImageUrl;
@end

@implementation AutoLoaderImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeMe];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initializeMe];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) initializeMe {
    self.backgroundColor = [UIColor clearColor];
    
    CGRect refFrame = self.frame;
    self.internalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, refFrame.size.width, refFrame.size.height)];
    //self.internalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 182, 153)];
    self.internalImageView.contentMode = UIViewContentModeScaleAspectFill;
//    self.internalImageView.contentMode = UIViewContentModeScaleAspectFit;

    self.internalImageView.image = nil;
    self.internalImageView.backgroundColor = [UIColor clearColor];
    self.internalImageView.clipsToBounds = YES;
    [self addSubview:self.internalImageView];
    
    self.internalImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.internalImageView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.internalImageView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.internalImageView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.internalImageView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    self.internalBusyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.internalBusyIndicator.frame = CGRectMake((refFrame.size.width - 24.0f)*0.5f, (refFrame.size.height - 24.0f)*0.5f, 24.0f, 24.0f);
    self.internalBusyIndicator.hidesWhenStopped = YES;
    [self addSubview:self.internalBusyIndicator];
    self.internalBusyIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.internalBusyIndicator addConstraint:[NSLayoutConstraint constraintWithItem:self.internalBusyIndicator
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                        constant:24.0f]];
    [self.internalBusyIndicator addConstraint:[NSLayoutConstraint constraintWithItem:self.internalBusyIndicator
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:24.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.internalBusyIndicator
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.internalBusyIndicator
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];

    
    self.clipsToBounds = YES;

}

-(void) loadImageAtUrl:(NSString *) aImageUrl withPlaceholderImageNameFromResource:(NSString *) aPlaceholderImageNameFromResource {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if (aImageUrl == nil) {
        [self.internalBusyIndicator stopAnimating];
        UIImage * aImg = [UIImage imageNamed:aPlaceholderImageNameFromResource];
        if (aImg) {
            self.internalImageView.image = aImg;
        } else {
            self.internalImageView.image = nil;
//            DebugLog(@"ERROR: Failed to laod %@", aPlaceholderImageNameFromResource);
        }
        return;
    }
    if ((self.currentImageUrl != nil) &&
        ([self.currentImageUrl caseInsensitiveCompare:aImageUrl] == NSOrderedSame)) {
        // Already processing same url, skip
        return;
    }
    
    self.currentImageUrl = aImageUrl;

    UIImage *cachedImage = [[Context getInstance] serverImageForUrl:aImageUrl];
    if (cachedImage != nil) {
        self.internalImageView.image = cachedImage;
        [self.internalBusyIndicator stopAnimating];
    } else {
        if (aPlaceholderImageNameFromResource) {
            UIImage * aImg = [UIImage imageNamed:aPlaceholderImageNameFromResource];
            if (aImg) {
                self.internalImageView.image = aImg;
            } else {
                self.internalImageView.image = nil;
//                DebugLog(@"ERROR: Failed to laod %@", aPlaceholderImageNameFromResource);
            }
        } else {
            self.internalImageView.image = nil;
        }
        [self.internalBusyIndicator startAnimating];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleServerImageDownloadSuccessful:) name:SERVER_IMAGE_DOWNLAD_SUCCESS_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleServerImageDownloadFailure:) name:SERVER_IMAGE_DOWNLAD_FAILURE_NOTIFICATION object:nil];
        

        [[Context getInstance] downloadImageWithCompletionBlock:^(NSString *url, BOOL downloadSuccess) {
            if ((downloadSuccess) &&
                (self.currentImageUrl != nil) &&
                ([self.currentImageUrl caseInsensitiveCompare:url] == NSOrderedSame)) {
                UIImage *cachedImage = [[Context getInstance]  serverImageForUrl:self.currentImageUrl];
                self.internalImageView.image = cachedImage;
            }
            [self.internalBusyIndicator stopAnimating];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        } forUrl:aImageUrl];
    }

}

-(void) loadImage:(UIImage *) aImage withTempName:(NSString *) aImageName {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ((self.currentImageUrl == nil) || (aImageName == nil) ||
        ([self.currentImageUrl caseInsensitiveCompare:aImageName] != NSOrderedSame)) {
        self.currentImageUrl = aImageName;
        self.internalImageView.image = aImage;
        [self.internalBusyIndicator stopAnimating];
    }
}

-(void) handleServerImageDownloadSuccessful:(NSNotification *) notification {
    if ((notification.userInfo) && ([notification.userInfo objectForKey:SERVER_IMAGE_DOWNLAD_URL_KEY])) {
        NSString * aUrl = [notification.userInfo objectForKey:SERVER_IMAGE_DOWNLAD_URL_KEY];
        if ((self.currentImageUrl) && ([self.currentImageUrl caseInsensitiveCompare:aUrl] == NSOrderedSame)) {
            UIImage *cachedImage = [[Context getInstance]  serverImageForUrl:self.currentImageUrl];
            self.internalImageView.image = cachedImage;
            [self.internalBusyIndicator stopAnimating];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) handleServerImageDownloadFailure:(NSNotification *) notification {
    if ((notification.userInfo) && ([notification.userInfo objectForKey:SERVER_IMAGE_DOWNLAD_URL_KEY])) {
        NSString * aUrl = [notification.userInfo objectForKey:SERVER_IMAGE_DOWNLAD_URL_KEY];
        if ((self.currentImageUrl) && ([self.currentImageUrl caseInsensitiveCompare:aUrl] == NSOrderedSame)) {
            [self.internalBusyIndicator stopAnimating];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

@end
