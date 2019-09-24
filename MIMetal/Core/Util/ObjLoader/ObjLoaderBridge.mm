//
//  ObjLoaderBridge.m
//  Mirage3D
//
//  Created by 影子.zsr on 2018/5/28.
//  Copyright © 2018年 影子. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjTransToBinary.h"
#include <string.h>
#import <SceneKit/SceneKit.h>
#import "ObjLoaderBridge.h"
#import <simd/simd.h>

@implementation ObjLoaderBridge

-(void)load:(NSString *)path{
    ObjTransToBinary a;
    const char *url = [path UTF8String];
    
    vector<float> _vs;
    vector<float> _vts;
    vector<float> _vns;
    vector<unsigned int> _face;
    try {
        a.ObjTransfer(url,&_vs,&_vns,&_vts,&_face);
    } catch (char *str) {
        NSLog(@"字符:%s",str);
    }
    
    
    _data_v = [NSMutableArray array];
    _data_vn = [NSMutableArray array];
    _data_vt = [NSMutableArray array];
    _data_face = [NSMutableArray array];
    
    for (int i = 0; i < _vs.size()/3; i++) {
        [_data_v addObject:@(_vs[i*3])];
        [_data_v addObject:@(_vs[i*3+1])];
        [_data_v addObject:@(_vs[i*3+2])];
        
        [_data_vn addObject:@(_vns[i*3])];
        [_data_vn addObject:@(_vns[i*3+1])];
        [_data_vn addObject:@(_vns[i*3+2])];
        
        [_data_vt addObject:@(_vts[i*2])];
        [_data_vt addObject:@(_vts[i*2+1])];
    }
    
    for (int i = 0; i < _face.size(); i++) {
        [_data_face addObject:@(_face[i])];
    }
    
}



@end








