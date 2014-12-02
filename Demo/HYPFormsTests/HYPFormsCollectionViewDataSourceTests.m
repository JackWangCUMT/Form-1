@import UIKit;
@import XCTest;

#import "HYPForm.h"
#import "HYPFormField.h"
#import "HYPFormTarget.h"
#import "HYPFormsCollectionViewDataSource.h"
#import "HYPFormsManager.h"

#import "NSJSONSerialization+ANDYJSONFile.h"

@interface HYPFormsCollectionViewDataSourceTests : XCTestCase

@property (nonatomic, strong) HYPFormsCollectionViewDataSource *dataSource;
@property (nonatomic, strong) HYPFormsManager *formsManager;

@end

@implementation HYPFormsCollectionViewDataSourceTests

- (void)setUp
{
    [super setUp];

    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"];

    HYPFormsLayout *layout = [[HYPFormsLayout alloc] init];

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:[[UIScreen mainScreen] bounds] collectionViewLayout:layout];

    self.formsManager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                initialValues:nil
                                             disabledFieldIDs:nil
                                                     disabled:NO];

    self.dataSource = [[HYPFormsCollectionViewDataSource alloc] initWithCollectionView:collectionView andFormsManager:self.formsManager];
}

- (void)tearDown
{
    [super tearDown];

    self.dataSource = nil;
}

- (void)testIndexInForms
{
    [self.dataSource processTarget:[HYPFormTarget hideFieldTargetWithID:@"postal_code"]];
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"postal_code"]];
    HYPFormField *field = [HYPFormField fieldWithID:@"postal_code" inForms:self.formsManager.forms withIndexPath:NO];
    NSUInteger index = [field indexInForms:self.formsManager.forms];
    XCTAssertEqual(index, 6);

    [self.dataSource processTarget:[HYPFormTarget hideFieldTargetWithID:@"image"]];
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"image"]];
    field = [HYPFormField fieldWithID:@"image" inForms:self.formsManager.forms withIndexPath:NO];
    index = [field indexInForms:self.formsManager.forms];
    XCTAssertEqual(index, 11);

    [self.dataSource processTargets:[HYPFormTarget hideFieldTargetsWithIDs:@[@"first_name", @"address", @"image"]]];
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"image"]];
    field = [HYPFormField fieldWithID:@"image" inForms:self.formsManager.forms withIndexPath:NO];
    index = [field indexInForms:self.formsManager.forms];
    XCTAssertEqual(index, 9);
    [self.dataSource processTargets:[HYPFormTarget showFieldTargetsWithIDs:@[@"first_name", @"address"]]];

    [self.dataSource processTargets:[HYPFormTarget hideFieldTargetsWithIDs:@[@"last_name", @"address"]]];
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"address"]];
    field = [HYPFormField fieldWithID:@"address" inForms:self.formsManager.forms withIndexPath:NO];
    index = [field indexInForms:self.formsManager.forms];
    XCTAssertEqual(index, 4);
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"last_name"]];
}

- (void)testFieldWithIDWithIndexPath
{
    HYPFormField *firstNameField = [self.dataSource fieldWithID:@"first_name" withIndexPath:YES];
    XCTAssertNotNil(firstNameField);
    XCTAssertEqualObjects(firstNameField.fieldID, @"first_name");

    [self.dataSource processTarget:[HYPFormTarget hideFieldTargetWithID:@"student"]];
    HYPFormField *studentField = [self.dataSource fieldWithID:@"student" withIndexPath:YES];
    XCTAssertNotNil(studentField);
    XCTAssertEqualObjects(studentField.fieldID, @"student");
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"student"]];

    [self.dataSource processTarget:[HYPFormTarget hideSectionTargetWithID:@"ansettelsesforhold-1"]];
    HYPFormField *temporaryEmployeeTypeField = [self.dataSource fieldWithID:@"temporary_employee_type" withIndexPath:YES];
    XCTAssertNotNil(temporaryEmployeeTypeField);
    XCTAssertEqualObjects(temporaryEmployeeTypeField.fieldID, @"temporary_employee_type");
    [self.dataSource processTarget:[HYPFormTarget showSectionTargetWithID:@"ansettelsesforhold-1"]];
}

- (void)testFieldValidation
{
    NSArray *fields = [self.dataSource invalidFields];

    XCTAssertNotNil(fields);
}

@end
