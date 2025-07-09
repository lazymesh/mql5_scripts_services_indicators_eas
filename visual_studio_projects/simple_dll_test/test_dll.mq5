#import "TestDLL.dll" int Test(); #import
void OnStart() { Print(Test()); } // Should print "42"