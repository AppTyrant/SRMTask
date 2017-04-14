# SRMTask
Objective-C wrapper for the srm command line tool.

# Sample use
```
SRMTask *srmTask = [[SRMTask alloc]initWithOverwriteMode:SRMOverwriteModeSimple];
NSError *error = nil;
if ([srmTask srmDeleteFileAtURL:aFileURL error:&error])
{
    NSLog(@"Removed: %@",aFileURL);
}
else
{
    //Check the error.
}
```
