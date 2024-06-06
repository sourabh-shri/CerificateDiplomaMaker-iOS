//
//  Context.h
//
//  Created by Bharat Biswal on 01/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>

#define SERVER_IMAGE_DOWNLAD_URL_KEY @"ServerImageDownloadUrlKey"
#define SERVER_IMAGE_DOWNLAD_SUCCESS_NOTIFICATION @"ServerImageDownloadSuccessNotification"
#define SERVER_IMAGE_DOWNLAD_FAILURE_NOTIFICATION @"ServerImageDownloadFailureNotification"

#define APP_REVIEW_URL_KEY @"appReviewUrlKey"
#define PRO_VERSION_KEY @"proVersionKey"
#define APPLE_APP_ID_KEY @"appleAppIdKey"
#define MAX_ALLOWED_CERTS_IN_FREE_VERSION -1

typedef void(^ImageDownloadCompletionBlock)(NSString * url, BOOL downloadSuccess);


@interface Context : NSObject {
}


/** 
  * Returns Singleton instance of this context class
  * @return singleton instance
  */
+ (Context *) getInstance;
/** 
  * Returns Directory path for Appplications Documents
  * @return path
  */
/** 
  * Returns Value for key
  * 
  * @param keyId Key string
  * 
  * @return value for the key 
  			return default value if entry not found
  			return nil if entry not found and no default value
  */
- (NSString *) getValue:(NSString *) keyId;
/** 
  * Sets Value for key
  * If val is 'nil', this will remove the entry for keyId from storage
  *
  * @param val Value to be set
  * @param keyId Key string
  * 
  * @return void
  */

-(void) setValue:(NSString *) val forKey:(NSString *) keyId;
- (NSString *) GetResourceDirectoryPath;
-(BOOL) FileExistsAtPath:(NSString*) path;
-(void) showAlert:(NSString *) title withMessage:(NSString *) msg;
-(void) showAlert:(NSString *) title withMessageArray: (NSArray *) stringArray;

-(UIImage *)resize:(UIImage *)imageToFitInBackground toSize:(CGSize)targetSize;
-(UIImage *) serverImageForUrl:(NSString *) aImageUrl;
-(void) downloadImageWithCompletionBlock:(ImageDownloadCompletionBlock) completionBlock forUrl:(NSString *) aImageUrl;

// Used in In app purchases
-(BOOL) isProVersion;
-(void) enableProVersion;
-(void) disableProVersion;


-(NSDictionary *)getTemplateForId:(NSString *)templateId;
-(void)createTemplateDictionary:(NSMutableArray *)aArray;
-(NSString *) getAppReviewURLForAppId:(NSString * )appId;

-(NSString *)getUniqueNameWithPrefix:(NSString *)prefix withSuffix:(NSString *) suffix;
-(NSString *) getImageStorageFullpathForFilename:(NSString *) fileName;


@end


