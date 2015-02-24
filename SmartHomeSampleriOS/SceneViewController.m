//
//  SceneViewController.m
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/20/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "SceneViewController.h"
#import "Scene.h"
#import "SceneInfo.h"
#import "AppDelegate.h"
#import <ConnectSDK/DLNAService.h>
#import <ConnectSDK/WebOSTVService.h>
#import <ConnectSDK/SSDPDiscoveryProvider.h>

@interface SceneViewController ()

@property(nonatomic , strong) DiscoveryManager *discoveryManager;
@property(nonatomic , strong) Scene *scene1;
@property(nonatomic , strong) Scene *scene2;

@end

@implementation SceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Scene" ofType:@"plist"];
    NSDictionary *contentDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSDictionary *scene1Dictionary = [[contentDictionary objectForKey:@"Scenes"] objectAtIndex:0];
    SceneInfo *sceneInfo = [[SceneInfo alloc] init];
    sceneInfo.mediaArray = [contentDictionary objectForKey:@"Media"];
    sceneInfo.currentMediaIndex = 0;
    sceneInfo.currentPosition = 0;
    self.scene1 = [[Scene alloc] initWithConfiguration:scene1Dictionary andSceneInfo:sceneInfo];
    
    NSDictionary *scene2Dictionary = [[contentDictionary objectForKey:@"Scenes"] objectAtIndex:1];
    self.scene2 = [[Scene alloc] initWithConfiguration:scene2Dictionary andSceneInfo:sceneInfo];
    
    // Do any additional setup after loading the view.
    _discoveryManager = [DiscoveryManager sharedManager];
    [_discoveryManager registerDeviceService:[DLNAService class] withDiscovery:[SSDPDiscoveryProvider class]];
    [_discoveryManager registerDeviceService:[WebOSTVService class] withDiscovery:[SSDPDiscoveryProvider class]];
    
    _discoveryManager.pairingLevel = DeviceServicePairingLevelOn;
    _discoveryManager.delegate = self;
    [_discoveryManager startDiscovery];
    
     [UIAppDelegate enableLocalHeartbeat];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)startScene1:(id)sender{
    [self.scene1 changeSceneState:Running sucess:^(id responseObject) {
        NSLog(@"Scene1 Started");
    } failure:^(NSError *error) {
        NSLog(@"Scene1 failure");
    }];
}

-(IBAction)startScene2:(id)sender{
    [self.scene2 changeSceneState:Running sucess:^(id responseObject) {
        NSLog(@"Scene2 Started");
    } failure:^(NSError *error) {
        NSLog(@"Scene2 failure");
    }];
}

-(IBAction)pauseScene1:(id)sender{
    [self.scene1 changeSceneState:Paused sucess:^(id responseObject) {
        NSLog(@"Scene1 Paused");
    } failure:^(NSError *error) {
        NSLog(@"Scene1 pause failure");
    }];
}

-(IBAction)pauseScene2:(id)sender{
    [self.scene2 changeSceneState:Paused sucess:^(id responseObject) {
        NSLog(@"Scene2 Paused");
    } failure:^(NSError *error) {
        NSLog(@"Scene2 pause failure");
    }];
}

-(IBAction)stopScene1:(id)sender{
    [self.scene1 changeSceneState:Stopped sucess:^(id responseObject) {
        NSLog(@"Scene1 Stopped");
    } failure:^(NSError *error) {
        NSLog(@"Scene1 stop failure");
    }];
}

-(IBAction)stopScene2:(id)sender{
    [self.scene2 changeSceneState:Stopped sucess:^(id responseObject) {
        NSLog(@"Scene2 Stoped");
    } failure:^(NSError *error) {
        NSLog(@"Scene2 stop failure");
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


# pragma mark - DiscoveryManagerDelegate methods

- (void)discoveryManager:(DiscoveryManager *)manager didFindDevice:(ConnectableDevice *)device
{
    if(device){
        
        NSLog(@"Device address %@",device.services);
        if(self.scene1 && self.scene2){
            NSDictionary *sceneDevice1 = [self.scene1.configuration valueForKey:@"device"];
            NSDictionary *sceneDevice2 = [self.scene2.configuration valueForKey:@"device"];
          
            if([device serviceWithName:kConnectSDKWebOSTVServiceId] && [[sceneDevice1 objectForKey:@"ip"] isEqualToString:device.address]){
                self.scene1.conectableDevice = device;
                [self.scene1 configureScene];
            }
            
            if([[sceneDevice2 objectForKey:@"ip"] isEqualToString:device.address]){
                self.scene2.conectableDevice = device;
                [self.scene2 configureScene];
            }
        }
    }
}

- (void)discoveryManager:(DiscoveryManager *)manager didLoseDevice:(ConnectableDevice *)device
{
    NSLog(@"Lost device %@",device.address);
}

- (void)discoveryManager:(DiscoveryManager *)manager didUpdateDevice:(ConnectableDevice *)device
{
    //Nothing
    if(device){
        
        NSLog(@"Device address %@",device.services);
        if(self.scene1 && self.scene2){
            NSDictionary *sceneDevice1 = [self.scene1.configuration valueForKey:@"device"];
            NSDictionary *sceneDevice2 = [self.scene2.configuration valueForKey:@"device"];
            
            if([device serviceWithName:kConnectSDKWebOSTVServiceId] && [[sceneDevice1 objectForKey:@"ip"] isEqualToString:device.address]){
                self.scene1.conectableDevice = device;
                [self.scene1 configureScene];
            }
            
            if([[sceneDevice2 objectForKey:@"ip"] isEqualToString:device.address]){
                self.scene2.conectableDevice = device;
                [self.scene2 configureScene];
            }
        }
    }
}

@end
