//
//  Context.m
//
//
#import "Context.h"

//#import "AnalyticsGoogle.h"
//#import "GAI.h"
//#import "GAIDictionaryBuilder.h"
//#import "GAIFields.h"
//#import "GAILogger.h"

#define IMAGES_STORAGE_SUBFOLDER_NAME @"ImagesStorage"
#define SERVER_IMAGES_DOWNLOAD_SUBFOLDER_NAME @"serverImages"
#define APP_CONFIG_FILENAME @"fewfer_celebvmfanreq_ferferfew.plist"
#define URL_FILE_MAP_FILENAME @"fewfer_urlfilemap_ferferfew.plist"

#define MAX_DISK_FOR_IMAGES 1048576000 // 1024*1024*100 = 100 MB

// This is a singleton class, see below
static Context *context_instance = nil;

@interface Context ()

@property (atomic, strong) NSMutableDictionary * m_settings;
@property (atomic, strong) NSMutableDictionary * imageUrlToFilePathMappingDict;
@property (atomic, strong) NSMutableDictionary * downloadUrlToCompletionBlockArrayDict;
@property (atomic, strong) NSMutableDictionary *downloadingPicURLsDict;

@property (atomic, retain) NSCache *serverImageCache;

@property (atomic, strong) NSDictionary *templatesDictionary;


/** 
  * Check if APP_CONFIG_FILENAME exists in docs folder
  */
-(void) loadExistingConfig;

@end

@implementation Context

@synthesize m_settings;
@synthesize downloadingPicURLsDict;
@synthesize imageUrlToFilePathMappingDict, downloadUrlToCompletionBlockArrayDict;
@synthesize serverImageCache;

- (id) init
{
	self = [super init];
	return self;
}

-(void) loadExistingConfig {

	// create a pointer to a dictionary
	NSDictionary *dictionary;
	// read "foo.plist" from application bundle
	NSString *localFileFullName = [[self getDocumentDirectory] stringByAppendingPathComponent:APP_CONFIG_FILENAME];
	if ([self FileExistsAtPath:localFileFullName] == true) {
		dictionary = [NSDictionary dictionaryWithContentsOfFile:localFileFullName];
		[self.m_settings setDictionary:dictionary];
	}
    localFileFullName = [[self getDocumentDirectory] stringByAppendingPathComponent:URL_FILE_MAP_FILENAME];
	if ([self FileExistsAtPath:localFileFullName] == true) {
		dictionary = [NSDictionary dictionaryWithContentsOfFile:localFileFullName];
		[self.imageUrlToFilePathMappingDict setDictionary:dictionary];
	}
}

-(void) createBaseDirectories {
    
    NSString * versionedDirectory = [self getDocumentDirectory];
	NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath:versionedDirectory])	//Does directory already exist?
	{
		if (![[NSFileManager defaultManager] createDirectoryAtPath:versionedDirectory
									   withIntermediateDirectories:NO
														attributes:nil
															 error:&error])
		{
//			DebugLog(@"Create directory error: %@", error);
		}
	}
    NSString * serverImagesDir = [self getServerImageDownloadDirectory];
	error=nil;
	if (![[NSFileManager defaultManager] fileExistsAtPath:serverImagesDir])	//Does directory already exist?
	{
		if (![[NSFileManager defaultManager] createDirectoryAtPath:serverImagesDir
									   withIntermediateDirectories:YES
														attributes:nil
															 error:&error])
		{
//			DebugLog(@"Create directory error: %@", error);
		}
	}
}

+ (Context *) getInstance 
{
    @synchronized(self) 
	{
        if (context_instance == nil) 
		{
            context_instance = [[Context alloc] init]; // assignment not done here
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:40];
            context_instance.m_settings = dict;
            dict = [[NSMutableDictionary alloc] initWithCapacity:40];
            context_instance.imageUrlToFilePathMappingDict = dict;
            dict = [[NSMutableDictionary alloc] initWithCapacity:40];
            context_instance.downloadUrlToCompletionBlockArrayDict = dict;
            dict = [[NSMutableDictionary alloc] initWithCapacity:40];
            context_instance.downloadingPicURLsDict = dict;
            context_instance.serverImageCache = [[NSCache alloc] init];
            [context_instance loadExistingConfig];
            [context_instance createBaseDirectories];
        }
    }
    return context_instance;
}

-(NSString *) getValue:(NSString *) keyId {
	NSString * ret = [m_settings objectForKey:keyId];
	if (ret != nil) 
		return ret;
	NSString * defVal = nil;
    
	if (defVal != nil) {
		//DebugLog(@"Context:getValue:Added default value '%@' for key '%@'",defVal, keyId);
		[m_settings setObject:defVal forKey:keyId];
		NSString *localFileFullName = [[self getDocumentDirectory] stringByAppendingPathComponent:APP_CONFIG_FILENAME];
		if ([m_settings writeToFile:localFileFullName atomically:YES] != YES) {
//			DebugLog(@"Context::getValue:ERROR Failed to save configuration.");
		}
	}

	ret = [m_settings objectForKey:keyId];
	if (ret != nil) 
		return ret;
	else  {
		return nil;
	}
}

-(void) setValue:(NSString *) val forKey:(NSString *) keyId {
	if ((keyId != nil) && (val != nil)) {
		//DebugLog(@"Context:setValue:value '%@' for key '%@'",val, keyId);
		[m_settings setObject:val forKey:keyId];
		NSString *localFileFullName = [[self getDocumentDirectory] stringByAppendingPathComponent:APP_CONFIG_FILENAME];
		if ([m_settings writeToFile:localFileFullName atomically:YES] != YES) {
//			DebugLog(@"Context::setValue:ERROR Failed to save configuration.");
		}
    }
}

-(void) setFilePath:(NSString *) filePath forUrl:(NSString *) url {
	if ((url != nil) && (filePath != nil)) {
		[self.imageUrlToFilePathMappingDict setObject:filePath forKey:url];
		NSString *localFileFullName = [[self getDocumentDirectory] stringByAppendingPathComponent:URL_FILE_MAP_FILENAME];
		if ([self.imageUrlToFilePathMappingDict writeToFile:localFileFullName atomically:YES] != YES) {
//			DebugLog(@"Context::setFilePath:ERROR Failed to save configuration.");
		}
    }
}

- (NSString *) GetResourceDirectoryPath
{
	return [[NSBundle mainBundle] resourcePath];
}

-(BOOL) FileExistsAtPath:(NSString*) path
{
	NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:path];
	const bool present = handle != nil;
	if(handle) [handle closeFile];
	return present;
}
-(void) showAlert:(NSString *) title withMessage:(NSString *) msg {
	
    NSString * aTitle = title;
    NSString * aMsg = msg;
    if (aTitle == nil)
        aTitle = @"";
    if (aMsg == nil)
        aMsg = @"";
//	DebugLog(@"ALERT: %@: %@",title, msg);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:aTitle message:aMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

-(void) showAlert:(NSString *) title withMessageArray: (NSArray *) stringArray {
    NSString * aTitle = title;
    NSMutableString * aMsg = [[NSMutableString alloc] initWithString:@""];
    if (aTitle == nil)
        aTitle = @"";
    if (stringArray != nil) {
        for (int i=0; i < [stringArray count]; i++) {
            [aMsg appendString:[stringArray objectAtIndex:i]];
            [aMsg appendString:@"\n"];
        }
    }
//	DebugLog(@"ALERT: %@:[%@]",title, aMsg);
    if ((aMsg != nil) && ([aMsg length] > 0) && ([aMsg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] > 0)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:aTitle message:aMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }

}


-(BOOL)isPad
{
    BOOL checkPad;
    NSRange range = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    if(range.location==NSNotFound)
    {
        checkPad=NO;
    }
    else {
        checkPad=YES;
    }
    return checkPad;
}

-(NSString *)getDocumentDirectory{
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return documentsDirectory;
}

-(NSString *)getServerImageDownloadDirectory {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * serverImageDownlaodDir = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@",SERVER_IMAGES_DOWNLOAD_SUBFOLDER_NAME]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:serverImageDownlaodDir isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:serverImageDownlaodDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return serverImageDownlaodDir;
}

-(BOOL)checkIsDeviceVersionHigherThanRequiredVersion:(NSString *)requiredVersion
{
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:requiredVersion options:NSNumericSearch] != NSOrderedAscending)
    {
        return YES;
    }
    return NO;
}

-(BOOL)screenPhysicalSizeForIPhoneClassic
{
    BOOL screenSize = YES;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height <= 480)
            screenSize = YES;  // iPhone 4S / 4th Gen iPod Touch or earlier
        else
            screenSize = NO;  // iPhone 5
    } else {
        screenSize = YES; // For iPad, show iPhone4 XIB for now
    }
    return screenSize;
}

-(NSString *) getXcodeAppVersionString {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    if (version == nil)
        version = @"";
    return [NSString stringWithFormat:@"%@ v%@ (%@)", name, version, build];
}

-(BOOL) isDeviceInPortraitMode{
    BOOL portraitOrientation = YES;
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (deviceOrientation != UIDeviceOrientationLandscapeLeft &&
        deviceOrientation != UIDeviceOrientationLandscapeRight)
    {
        portraitOrientation = YES;
    }else{
        portraitOrientation =  NO;
    }
    
    return portraitOrientation;
}

-(long long int) getEpochTimeStampOfGMTTimeInMilliSecs {
    long long int elapseMillis = [[NSDate date] timeIntervalSince1970] * 1000;
    return elapseMillis;
}


-(NSDate*) convertToGMT:(NSDate*)sourceDate{
    NSTimeZone* currentTimeZone = [NSTimeZone systemTimeZone];
    NSTimeInterval gmtInterval = [currentTimeZone secondsFromGMTForDate:sourceDate];
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:(-1.0f*gmtInterval) sinceDate:sourceDate];
    return destinationDate;
}

-(NSString*) convertToGMTAndReturnStringForDate:(NSDate*)sourceDate withFormat:(NSString *) format {
    NSTimeZone* currentTimeZone = [NSTimeZone systemTimeZone];
    NSTimeInterval gmtInterval = [currentTimeZone secondsFromGMTForDate:sourceDate];
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:(-1.0f*gmtInterval) sinceDate:sourceDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *timeGmtStr = [dateFormatter stringFromDate:destinationDate];
    //[dateFormatter release];
    //[destinationDate release];
    return timeGmtStr;
}

-(NSString*) getFormattedDate:(NSDate*)sourceDate withFormat:(NSString *) format {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *str = [dateFormatter stringFromDate:sourceDate];
    //[dateFormatter release];
    //[destinationDate release];
    return str;
}


-(NSDate *) getLocalNSDateForGMTDateString : (NSString *) gmtDateStr withFormat:(NSString *) format {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate * gmtDate = [dateFormatter dateFromString:gmtDateStr];
    //[dateFormatter release];
    
    NSTimeZone* currentTimeZone = [NSTimeZone systemTimeZone];
   // NSTimeZone *currentTimeZone = [NSTimeZone timeZoneWithName:@"Australia/Melbourne"];
    NSTimeInterval gmtInterval = [currentTimeZone secondsFromGMTForDate:[NSDate date]];
    NSDate* destinationDate = [NSDate dateWithTimeInterval:gmtInterval sinceDate:gmtDate];
    
    return destinationDate;
}


- (NSString*) convertDateString:(NSString*)sourceDateStr fromFormat:(NSString *)fromFormat toFormat:(NSString *) toFormat {
    if (sourceDateStr == nil)
        return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:fromFormat];
    NSDate * aDate = [dateFormatter dateFromString:sourceDateStr];
    if (aDate != nil) {
        [dateFormatter setDateFormat:toFormat];
        NSString *timeStr = [dateFormatter stringFromDate:aDate];
        return timeStr;
    }
    return nil;
}

-(NSString*)getDifferenceBetweenTwoDatesFromDateString:(NSString*)fromDateStr toDateString:(NSString*)toDateStr withDateFormat:(NSString*)dateFormat {
    if ((fromDateStr == nil)||(fromDateStr == nil))
        return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSDate * fromDate = [dateFormatter dateFromString:fromDateStr];
    NSDate * toDate = [dateFormatter dateFromString:toDateStr];

    if ((fromDate != nil)&&(toDate!= nil)) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute
                                                   fromDate:fromDate
                                                     toDate:toDate
                                                    options:0];
        NSString *timeStr = [NSString stringWithFormat:@"%ld.%ld",(long)components.hour,(long)components.minute];
        return timeStr;

    }
    return nil;
}

-(NSString*)convertDateStringToDayAndDate:(NSString*)sourceDateStr withDateFormat:(NSString*)dateFormat {
    if (sourceDateStr == nil)
        return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSDate * aDate = [dateFormatter dateFromString:sourceDateStr];
    if (aDate != nil) {
        [dateFormatter setDateFormat:@"EEEE MM/dd/YYYY"];
        NSString *timeStr = [dateFormatter stringFromDate:aDate];
        return timeStr;
    }
    return nil;
}


-(UIImage *)resize:(UIImage *)imageToFitInBackground toSize:(CGSize)targetSize
{
    if (imageToFitInBackground == nil)
        return nil;
    
    UIImage *sourceImage = imageToFitInBackground;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // make image center aligned
        if (widthFactor < heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor > heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    CGSize scaledSize = CGSizeMake(scaledWidth, scaledHeight);
    //UIGraphicsBeginImageContext(targetSize);
    UIGraphicsBeginImageContext(scaledSize);
    
    CGRect thumbnailRect = CGRectZero;
    //thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil)
//        DebugLog(@"could not scale image");
        NSLog(@"okeay");
    
    return newImage ;
}


-(NSString *) getDisplayableProfileNameFromFirstName:(NSString *) fName withLastname:(NSString *) lName
{
    NSString * cFname = fName;
    NSString * cLname = lName;
    if (cFname == nil) { cFname = @""; }
    if (cLname == nil) { cLname = @""; }
    NSString * str = [NSString stringWithFormat:@"%@ %@",
                      [cFname capitalizedString],
                      [cLname capitalizedString]];
//    DebugLog(@"%@",str);

    return str;
}

//-(NSString *) getDisplayableTimeStringForActivityTimeStamp:(NSString *) activityTimeStampInMillisStr withFormat:(NSString *) displayTimeFormat {
//    NSTimeInterval t = ([activityTimeStampInMillisStr longLongValue]/1000);
//    NSDate * d = [NSDate dateWithTimeIntervalSince1970:t];
//    NSDateFormatter * df = [[NSDateFormatter alloc] init];
//    [df setDateFormat:displayTimeFormat];
//    return [df stringFromDate:d];
//}

-(NSString *) getDisplayableTimeStringForTimeStamp:(NSString *) timeStampInMillisStr withFormat:(NSString *) displayTimeFormat {
    NSTimeInterval t = ([timeStampInMillisStr longLongValue]/1000);
    NSDate * d = [NSDate dateWithTimeIntervalSince1970:t];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:displayTimeFormat];
    return [df stringFromDate:d];
}

-(NSDate *) getNSDateForTimeStamp:(NSString *) timeStampInMillisStr {
    NSTimeInterval t = ([timeStampInMillisStr longLongValue]/1000);
    NSDate * d = [NSDate dateWithTimeIntervalSince1970:t];
    return d;
}

-(NSString *) getDisplayableTimeDiffForServerTimeString:(NSString *) serverTime withFormat:(NSString *) displayTimeFormat {
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:displayTimeFormat];
    NSDate * d = [df dateFromString:serverTime];
    if (d == nil) { return serverTime; }
    
    NSDate * now = [NSDate date];
    
    NSTimeInterval t = [now timeIntervalSinceDate:d];
    if (t < 24*60*60) {
        return @"today";
    }
    else if (t < 2*24*60*60) {
        return @"yesterday";
    }
    else if (t < 2*30*24*60*60) {
        int days = (int)(((long int)t)/(24*60*60));
        return [NSString stringWithFormat:@"%d days ago",days];
    } else {
        int months = (int)(((long int)t)/(30*24*60*60));
        return [NSString stringWithFormat:@"%d months ago",months];
    }
    return @"";
}


-(UIImage *) serverImageForUrl:(NSString *) aImageUrl {
    if ((aImageUrl == nil) || ([self.imageUrlToFilePathMappingDict objectForKey:aImageUrl] == nil)) {
        return nil;
    }
    NSString * filePath = [self.imageUrlToFilePathMappingDict objectForKey:aImageUrl];
    if ((filePath == nil) || ([filePath length] < 1)) { return nil; }
    BOOL isDir = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    if ((!exists) || (isDir)) {
        return nil;
    }
    
    UIImage * aImage = [self.serverImageCache objectForKey:aImageUrl];
    if (aImage != nil) { return aImage; }
    aImage = [UIImage imageWithContentsOfFile:filePath];
    if (aImage != nil) {
        [self.serverImageCache setObject:aImage forKey:aImageUrl];
    }
    return aImage;
}

//-(void) downloadImageForUrl:(NSString *) aImageUrl
-(void) downloadImageWithCompletionBlock:(ImageDownloadCompletionBlock) completionBlock forUrl:(NSString *) aImageUrl
{

    if ((aImageUrl == nil) || ([aImageUrl length] < 1)) { return; }
    
    if  ([self.downloadingPicURLsDict objectForKey:aImageUrl] != nil) {
        // already scheduled, no need to schedule again
        return;
    }
    
    if (completionBlock != nil) {
        [self.downloadUrlToCompletionBlockArrayDict setObject:completionBlock forKey:aImageUrl];
    }
    
    [self.downloadingPicURLsDict setObject:aImageUrl forKey:aImageUrl];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //DebugLog(@"Starting download of %@",aImageUrl);
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aImageUrl]];
        // Update the UI
        if (imageData != nil) {
            // First check if disk size exceeds allocate, if yes, delete files to half
            if ([self sizeOfFolderAtPath:[self getServerImageDownloadDirectory]] > MAX_DISK_FOR_IMAGES) {
                [self deleteHalfOfFilesFromFolderAtPath:[self getServerImageDownloadDirectory]];
            }
            NSString * imageName = [aImageUrl lastPathComponent];
            NSDateFormatter * df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
            NSString * randomImageFileName = [NSString stringWithFormat:@"%@_%d_%d_%@",
                                              [df stringFromDate:[NSDate date]],
                                              arc4random()%999,
                                              arc4random()%999,
                                              imageName];
            NSString * fullPath = [NSString stringWithFormat:@"%@/%@",
                                   [self getServerImageDownloadDirectory], randomImageFileName];
            if ([imageData writeToFile:fullPath atomically:YES] == YES) {
                [self setFilePath:fullPath forUrl:aImageUrl];
                [self.downloadingPicURLsDict removeObjectForKey:aImageUrl];
                UIImage * img = [UIImage imageWithData:imageData];
                if (img != nil) {
                    [self.serverImageCache setObject:img forKey:aImageUrl];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    //NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:fullPath, aImageUrl, nil];
                    //[[NSNotificationCenter defaultCenter] postNotificationName:SERVER_IMAGE_DOWNLADED_NOTIFICATION object:nil userInfo:userInfo];
                    if ([self.downloadUrlToCompletionBlockArrayDict objectForKey:aImageUrl] != nil) {
                        ImageDownloadCompletionBlock aBlock = [self.downloadUrlToCompletionBlockArrayDict objectForKey:aImageUrl];
                        if (aBlock) {
                            aBlock(aImageUrl, YES);
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:SERVER_IMAGE_DOWNLAD_SUCCESS_NOTIFICATION object:nil userInfo:
                         [NSDictionary dictionaryWithObjectsAndKeys:aImageUrl,SERVER_IMAGE_DOWNLAD_URL_KEY, nil]];
                    }
                });
            } else {
//                DebugLog(@"ERROR: Failed to save downloaded file %@ at local path %@", imageName, fullPath);
                if ([self.downloadUrlToCompletionBlockArrayDict objectForKey:aImageUrl] != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ImageDownloadCompletionBlock aBlock = [self.downloadUrlToCompletionBlockArrayDict objectForKey:aImageUrl];
                        if (aBlock) {
                            aBlock(aImageUrl, NO);
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:SERVER_IMAGE_DOWNLAD_FAILURE_NOTIFICATION object:nil userInfo:
                         [NSDictionary dictionaryWithObjectsAndKeys:aImageUrl,SERVER_IMAGE_DOWNLAD_URL_KEY, nil]];
                    });
                }
            }
        }
    });
    
}

-(unsigned long long) sizeOfFolderAtPath:(NSString *)folderPath {
    if ((folderPath == nil) || ([folderPath length] < 1) ||
        ([[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:nil] == NO)) {
        return 0;
    }
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir];
    if (isDir == NO) { return 0; }

    NSError * err = nil;
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:&err];
    if (err != nil) { return 0; }
    unsigned long long size = 0;
    for (int i=0; i < [files count]; i++) {
        NSString * fileName = [files objectAtIndex:i];
        NSString * fullPath = [folderPath stringByAppendingPathComponent:fileName];
        isDir = NO;
        BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
        if (!isExists) { continue; }
        if (isDir) {
            size += [self sizeOfFolderAtPath:fullPath];
        } else {
            err = nil;
            NSDictionary* attr = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&err];
            if (attr != nil) {
                size += [attr fileSize];
            }
        }
    }
    
    return size;
}

-(void) deleteHalfOfFilesFromFolderAtPath:(NSString *)folderPath {
//    DebugLog(@"%@ exceeds allocation. Deleting files", folderPath);
    if ((folderPath == nil) || ([folderPath length] < 1) ||
        ([[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:nil] == NO)) {
        return;
    }
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir];
    if (isDir == NO) { return; }
    
    NSError * err = nil;
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:&err];
    if (err != nil) { return; }
    for (int i=0; i < [files count]; i++) {
        NSString * fileName = [files objectAtIndex:i];
        NSString * fullPath = [folderPath stringByAppendingPathComponent:fileName];
        isDir = NO;
        BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
        if (!isExists) { continue; }
        if (isDir) {
            // Do not delete folders, delete only files in side it
            [self deleteHalfOfFilesFromFolderAtPath:fullPath];
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        }
    }
}
// requir func for in app purchases
-(BOOL) isProVersion {
    NSString * str = [self getValue:PRO_VERSION_KEY];
    if ((str == nil) || ([str length] < 1) ||
        ([str caseInsensitiveCompare:@"0"] == NSOrderedSame)) {
        return NO;
    }
    return YES;
}

-(void) enableProVersion {
    [self setValue:@"1" forKey:PRO_VERSION_KEY];
}

-(void) disableProVersion {
    [self setValue:@"0" forKey:PRO_VERSION_KEY];
}

-(NSDictionary *)getTemplateForId:(NSString *)templateId {
    if ((templateId != nil) && ([templateId length] > 0)) {
        NSLog(@"dis... %@", self.templatesDictionary);
        if ([self.templatesDictionary objectForKey:templateId] != nil) {
            NSLog(@"%@", [self.templatesDictionary objectForKey:templateId]);
            return [self.templatesDictionary objectForKey:templateId];
        }
        return nil;
    }
    return nil;
}

-(void)createTemplateDictionary:(NSMutableArray *)aArray{
    if ((aArray != nil) && ([aArray count] > 0)) {
        NSMutableDictionary * tDicts = [[NSMutableDictionary alloc]initWithCapacity:3];
        for (int i = 0; i < [aArray count]; i++) {
            NSDictionary *aDict = [aArray objectAtIndex:i];
            [tDicts setObject:aDict forKey:[NSString stringWithFormat:@"%@",[aDict objectForKey:@"templateId"]]];
        }
        NSLog(@"mark...%@", tDicts);
        self.templatesDictionary = tDicts.copy ;
    }
    NSLog(@"writeToTemplateDictionary [%@]",self.templatesDictionary);
}

-(NSString *) getAppReviewURLForAppId:(NSString * )appId
{
    static NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%@";
    static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
    
    return [NSString stringWithFormat:([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f)? iOS7AppStoreURLFormat: iOSAppStoreURLFormat, appId]; // Would contain the right link
    
}
    
-(NSString *)getUniqueNameWithPrefix:(NSString *)prefix withSuffix:(NSString *) suffix
{
    return [NSString stringWithFormat:@"%@%@%@",
            prefix,
            [self getFormattedDate:[NSDate date] withFormat:@"yyyy-MM-dd-HH-mm-ss"],
            suffix];
}

-(NSString *) getImageStorageFullpathForFilename:(NSString *) fileName {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * imageStorageDir = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@",IMAGES_STORAGE_SUBFOLDER_NAME]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageStorageDir isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageStorageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [imageStorageDir stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
}


@end
