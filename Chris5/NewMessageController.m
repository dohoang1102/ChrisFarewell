//
//  NewMessageController.m
//  Chris5
//
//  Created by Igor Zevaka on 2/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewMessageController.h"
#import "QuartzCore/QuartzCore.h"
#import "Messages.h"

#define KEYBOARD_PORTRAIT 212
#define KEYBOARD_LANDSCAPE 162


@implementation NewMessageController

@synthesize delegate;
@synthesize messageTextView;
@synthesize fromTextField;
@synthesize message = _message;
@synthesize button;
@synthesize buttonCamera;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (IBAction)cancel:(id)sender
{
    [self.delegate detailsControllerDidCancel:self];
}

- (IBAction)done:(id)sender
{
    if (fromTextField.text.length || messageTextView.text.length) {
    
        if (!self.message)
        {
            self.message = [[Message alloc] init];
        }
        _message.from = fromTextField.text;
        _message.message = messageTextView.text;
    }
    
    [self.delegate detailsControllerDidSave:self];
}

#pragma mark - View lifecycle

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [messageTextView resignFirstResponder];    
    [fromTextField resignFirstResponder];
    [super touchesEnded:touches withEvent:event];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditMessage"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		MessageEditController  *controller = [[navigationController viewControllers] objectAtIndex:0];
        controller.message = messageTextView.text;
		controller.delegate = self;
	}
}

- (void)messageEditControllerDidCancel:(MessageEditController*)controller
{
    [self dismissModalViewControllerAnimated:YES];   
}

- (void)messageEditControllerDidSave:(MessageEditController*)controller
{
    messageTextView.text = controller.message;
    [self dismissModalViewControllerAnimated:YES];
}


- (CGRect) calculateKeyboardFieldsWithUp:(BOOL) up {
    
    int movementDistance = KEYBOARD_PORTRAIT; 
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        movementDistance = KEYBOARD_LANDSCAPE; 
    }
    
    int xMovement = 0, yMovement = 0;
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait){
        yMovement = (up ? -movementDistance : movementDistance);        
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        yMovement = (up ? movementDistance : -movementDistance);                
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        xMovement = (up ? -movementDistance : movementDistance);        
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        xMovement = (up ? movementDistance : -movementDistance);                
    }
    
    
    return CGRectOffset(self.view.frame, 0, xMovement + yMovement);
}

- (void) animateTextFieldWithUp: (BOOL) up
{
    const float movementDuration = 0.3f; // tweak as needed
    
    CGRect viewport = [self calculateKeyboardFieldsWithUp: up];
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    self.view.frame = viewport;
    
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextFieldWithUp: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextFieldWithUp: NO];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

-(void)showCamera:(id)sender{

    // Set up the image picker controller and add it to the view
    UIImagePickerController  *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.allowsEditing = YES;
    
    imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    // Show image picker
    [self presentModalViewController:imagePickerController animated:YES];
    
}
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];

    buttonCamera.imageView.image = image;
    if (!self.message) {
        self.message = [[Message alloc] init];
        self.message.photo = image;
    }

    // Save image (TODO)
    //UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

    [self dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    messageTextView.layer.cornerRadius = 10;
    
    messageTextView.text = self.message.message;
    fromTextField.text = self.message.from;
    if (self.message.photo) 
    {
        buttonCamera.imageView.image = self.message.photo;
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.interfaceOrientation != interfaceOrientation) 
    {
        [self.fromTextField resignFirstResponder];
    }
    // Return YES for supported orientations
    return YES;
}

@end
