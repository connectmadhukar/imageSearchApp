//
//  SearchCollectionViewController.h
//  pixster
//
//  Created by Madhukar Mulpuri on 1/29/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchTextboxWidget;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewWidget;

@end
