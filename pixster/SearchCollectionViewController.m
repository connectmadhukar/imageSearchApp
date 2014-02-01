//
//  SearchCollectionViewController.m
//  pixster
//
//  Created by Madhukar Mulpuri on 1/29/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "SearchCollectionViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "CollectionCell.h"



@interface SearchCollectionViewController ()
@property (nonatomic, strong) NSMutableArray *imageResults;
@property (nonatomic) NSInteger start;
@property (nonatomic, strong) NSString *searchString;
@end

@implementation SearchCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Pixster";
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"images.jpeg"]];
        self.imageResults = [NSMutableArray array];
        self.start = 0;
        self.collectionViewWidget.bounces=true;
        self.collectionViewWidget.alwaysBounceVertical = true;
        //self.searchTextboxWidget.delegate = self;
    }
     NSLog(@"loading the SearchViewController");
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *searchResultCellNib = [UINib nibWithNibName:@"CollectionCell" bundle:nil];
    [self.collectionViewWidget registerNib:searchResultCellNib forCellWithReuseIdentifier:@"CollectionCell"];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// UICollectionViewDataSource Implementation start
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageResults count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"cellForItemAtIndexPath");
    static NSString *cellIdentifier = @"CollectionCell";
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor redColor];
    UIImageView *imageView = cell.searchResultCellImageView;
    
    // Clear the previous image
    imageView.image = nil;
    [imageView setImageWithURL:[NSURL URLWithString:[self.imageResults[indexPath.row] valueForKeyPath:@"tbUrl"]]];
    return cell;
}
// UICollectionViewDataSource Implementation END


//pragma mark - UISearchDisplay delegate

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    [self.imageResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    NSLog(@"searchBarSearchButtonClicked");
   
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    self.searchString = searchBar.text;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"searchBarSearchButtonClicked");
        id results = [JSON valueForKeyPath:@"responseData.results"];
        if ([results isKindOfClass:[NSArray class]]) {
            [self.imageResults removeAllObjects];
            [self.imageResults addObjectsFromArray:results];
            [self.collectionViewWidget reloadData];
            NSURL *imageURL = [NSURL URLWithString:[self.imageResults[0] valueForKeyPath:@"url"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithData:imageData]];
            [self.view endEditing:YES];
            self.start += 4;
        }
       // NSLog(@"%@",results);
    } failure:nil];
    
    [operation start];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
        NSLog(@"searchBarTextDidBeginEditing");
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
        NSLog(@"searchBarShouldEndEditing");
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}

//pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize tbSize = CGSizeMake([[self.imageResults[indexPath.row]  valueForKeyPath:@"tbWidth"] intValue],[[self.imageResults[indexPath.row] valueForKeyPath:@"tbHeight"] intValue]);
    
    CGSize retval = tbSize.width > 0 ? tbSize : CGSizeMake(100, 100);
    //NSLog(@"%f %f",retval.width, retval.height);
    retval.height += 10; retval.width += 10;
    //NSLog(@"%f %f",retval.width, retval.height);
    return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
 //       NSLog(@"scrollViewDidEndDragging");
    if (!decelerate) {
       // [self updateStuff];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
   
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
         NSLog(@"scrollViewDidEndDecelerating");
      [self fetchMoreImages];
    }

    //[self updateStuff];
}

- (void) fetchMoreImages {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&start=%d", [self.searchString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], self.start]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        if ([results isKindOfClass:[NSArray class]]) {
            //[self.imageResults removeAllObjects];
            [self.imageResults addObjectsFromArray:results];
            [self.collectionViewWidget reloadData];
            self.start += 4;
            
        }
       // NSLog(@"%@",results);
    } failure:nil];
    
    [operation start];
}

@end
