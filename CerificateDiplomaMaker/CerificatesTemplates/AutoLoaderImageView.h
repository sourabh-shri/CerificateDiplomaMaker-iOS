//
//  AutoLoaderImageView.h
//  MiEd
//
//  Created by Venus on 8/24/14.
//  Copyright (c) 2014 jupiter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoLoaderImageView : UIView

-(void) loadImageAtUrl:(NSString *) aImageUrl withPlaceholderImageNameFromResource:(NSString *) aPlaceholderImageNameFromResource;
-(void) loadImage:(UIImage *) aImage withTempName:(NSString *) aImageName;
@property (nonatomic, strong) UIActivityIndicatorView * internalBusyIndicator;
@property (nonatomic, strong) UIImageView * internalImageView;



@end
