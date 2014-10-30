//
//  MBTilesPlugin.m
//
//  Created on 19/03/14.
//
//

#import "MBTilesPlugin.h"
#import "MBTilesConstant.h"


@implementation MBTilesPlugin

@synthesize dbmap;

- (void)open:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        
        NSDictionary* dict = [command.arguments objectAtIndex:0];
        // get the url and name
        NSString* name = nil;
        if ([dict objectForKey:KEY_NAME] != nil) {
            name = dict[KEY_NAME];
        }
        NSString* url = nil;
        if ([dict objectForKey:KEY_URL] != nil) {
            url = dict[KEY_URL];
        }
        
        if (dbmap == nil)
            dbmap = [NSMutableDictionary init];
        
        MBTilesActions* tilesActions = [dbmap objectForKey:name];
        if (tilesActions != nil)
            [tilesActions close];
        else
            [dbmap setObject:tilesActions forKey:name];
        
        // init db with name
        CDVFile* filePlugin = [self.commandDelegate getCommandInstance:@"File"];
            
        tilesActions = [[MBTilesActions alloc] initWithNameAndUrl:name withCDVFile:filePlugin withUrl:url];
        [tilesActions open:name];
        if ([tilesActions isOpen]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        
        // The sendPluginResult method is thread-safe.
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)get_tile:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        
        NSString* name = [command.arguments objectAtIndex:0];
        NSDictionary* dict = [command.arguments objectAtIndex:1];
        
        MBTilesActions* tilesActions = [dbmap objectForKey:name];
        
        // get zoom_level column and row
        int z = [dict[KEY_Z] intValue];
        int x = [dict[KEY_X] intValue];
        int y = [dict[KEY_Y] intValue];
        if (z && y && x) {
            
            // test is open
            if ([tilesActions isOpen]) {
                // get tiles
                NSDictionary* data = [tilesActions getTile:z columnValue:x rowValue:y];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION];
        }
            
        // The sendPluginResult method is thread-safe.
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}


@end
