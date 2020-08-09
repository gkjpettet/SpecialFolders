#tag Module
Protected Module SpecialFolders
	#tag Method, Flags = &h1
		Protected Function AppParent() As FolderItem
		  Return App.ExecutableFile.Parent
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function AppSupport() As FolderItem
		  ///
		  ' Returns the application support folder.
		  '
		  ' - Notes:
		  ' Return a FolderItem with the path:
		  '   Mac: ~/Library/Application Support/[bundle identifier]
		  '   Windows: \Users\[user]\AppData\Roaming\[app name]
		  '   Linux: /home/UserName/.[app name]
		  ///
		  
		  Var f As FolderItem = SpecialFolder.ApplicationData
		  
		  If f = Nil Then Return Nil
		  
		  #If TargetMacOS Then
		    Return f.Child(App.BundleIdentifier)
		    
		  #ElseIf TargetWindows Then
		    Return f.Child(ThisAppName)
		    
		  #ElseIf TargetLinux Then
		    Return f.Child("." + ThisAppName)
		    
		  #EndIf
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320746869732061707027732062756E646C65206964656E746966696572206F6E206D61634F53206F7220616E20656D70747920737472696E67206F6E206F7468657220706C6174666F726D732E
		Function BundleIdentifier(Extends a As Application) As String
		  ///
		  ' Returns this app's bundle identifier on macOS or an empty string on other platforms.
		  ///
		  
		  #Pragma Unused a
		  
		  Static mBundleIdentifier As String
		  
		  #If TargetMacOS
		    If mBundleIdentifier = "" Then
		      Declare Function mainBundle Lib "AppKit" Selector "mainBundle" (NSBundleClass As Ptr) As Ptr
		      Declare Function NSClassFromString Lib "AppKit" (className As CFStringRef) As Ptr
		      Declare Function getValue Lib "AppKit" Selector "bundleIdentifier" (NSBundleRef As Ptr) As CfStringRef
		      mBundleIdentifier = getValue(mainBundle(NSClassFromString("NSBundle")))
		    End If
		  #EndIf
		  
		  Return mBundleIdentifier
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 52657475726E73207468652061707027732062756E646C65206469726563746F7279206F6E206D61634F53206F722074686520706172656E7420666F6C646572206F662074686520617070206F6E2057696E646F777320616E64204C696E75782E
		Protected Function BundleParent() As FolderItem
		  ///
		  ' Returns the app's bundle directory on macOS or the parent folder of the app on Windows and Linux.
		  ///
		  
		  #If TargetMacOS Then
		    Static mBundlePath As folderitem
		    
		    If mBundlePath = Nil Or mBundlePath.exists = False Then
		      Declare Function NSClassFromString Lib "AppKit" (className As CFStringRef) As Ptr
		      Declare Function mainBundle Lib "AppKit" Selector "mainBundle" (NSBundleClass As Ptr) As Ptr
		      Declare Function resourcePath Lib "AppKit" Selector "bundlePath" (NSBundleRef As Ptr) As CfStringRef
		      mBundlePath = GetFolderItem(resourcePath(mainBundle(NSClassFromString( "NSBundle"))), FolderItem.PathTypeNative)
		    End If
		    
		    Return mBundlePath
		    
		  #ElseIf TargetWindows Or TargetLinux Then
		    Return App.ExecutableFile.Parent
		  #EndIf
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Contents() As FolderItem
		  #If TargetMacOS Then
		    Return App.ExecutableFile.Parent.Parent
		  #ElseIf TargetWindows Or TargetLinux Then
		    Return App.ExecutableFile.Parent
		  #EndIf
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 52657475726E7320746865206C6F636174696F6E20796F752073686F756C642075736520746F2073746F72652070726976617465206672616D65776F726B73202F206C69627261726965732E
		Protected Function Frameworks() As FolderItem
		  ///
		  ' Returns the location you should use to store private frameworks / libraries.
		  ///
		  
		  #If TargetMacOS Then
		    Static mFrameworks As folderitem
		    
		    If mFrameworks = Nil Or Not mFrameworks.Exists Then
		      Declare Function NSClassFromString Lib "AppKit" (className As CFStringRef) As Ptr
		      Declare Function mainBundle Lib "AppKit" Selector "mainBundle" (NSBundleClass As Ptr) As Ptr
		      Declare Function resourcePath Lib "AppKit" Selector "privateFrameworksPath" (NSBundleRef As Ptr) As CfStringRef
		      mFrameworks = GetFolderItem(resourcePath(mainBundle(NSClassFromString("NSBundle"))), FolderItem.PathTypeNative)
		    End If
		    
		    Return mFrameworks
		    
		  #ElseIf TargetWindows Or TargetLinux Then
		    Var fLibsFolder As FolderItem = App.ExecutableFile.Parent.Child("Libs")
		    
		    // Old style libs folder?
		    If fLibsFolder <> Nil And fLibsFolder.Exists Then
		      Return fLibsFolder
		    End If
		    
		    // New style libs folder?
		    fLibsFolder = App.ExecutableFile.Parent.Child(ThisAppName + " Libs")
		    If fLibsFolder <> Nil And fLibsFolder.exists = True Then
		      Return fLibsFolder
		    End If
		    
		    // Neither was found at this point.
		    Return Nil
		  #EndIf
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 52657475726E7320746865206C6F636174696F6E20746865206170702073686F756C642075736520746F2073746F72657320697473207265736F75726365732E
		Protected Function Resources() As FolderItem
		  ///
		  ' Returns the location the app should use to stores its resources.
		  ///
		  
		  #If TargetMacOS Then
		    Static mResourcesFolder As folderitem
		    
		    If mResourcesFolder = Nil Or mResourcesFolder.exists = False Then
		      Declare Function NSClassFromString Lib "AppKit" (className As CFStringRef) As Ptr
		      Declare Function mainBundle Lib "AppKit" Selector "mainBundle" (NSBundleClass As Ptr) As Ptr
		      Declare Function resourcePath Lib "AppKit" Selector "resourcePath" (NSBundleRef As Ptr) As CfStringRef
		      mResourcesFolder = GetFolderItem(resourcePath(mainBundle(NSClassFromString("NSBundle"))), FolderItem.PathTypeNative)
		    End If
		    
		    Return mResourcesFolder
		    
		  #ElseIf TargetWindows Or TargetLinux Then
		    Var fLibsFolder As FolderItem = App.ExecutableFile.Parent.Child("Resources")
		    
		    // Old style resources folder?
		    If fLibsFolder <> Nil And fLibsFolder.Exists Then
		      Return fLibsFolder
		    End If
		    
		    // New style resources folder?
		    fLibsFolder = App.ExecutableFile.Parent.Child(ThisAppName + " Resources")
		    If fLibsFolder <> Nil And fLibsFolder.Exists Then
		      Return fLibsFolder
		    End If
		    
		    // Neither was found at this point.
		    Return Nil
		  #EndIf
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 52657475726E732074686973206170702773206E616D652E
		Private Function ThisAppName() As String
		  ///
		  ' Returns this app's name.
		  ///
		  
		  Return ReplaceAll(App.ExecutableFile.Name, ".exe", "")
		  
		End Function
	#tag EndMethod


	#tag Note, Name = About
		About:
		     This module makes it easier to access executable relative files since Xojo
		     does not include a SepcialFolder.Resources or the like.
		
		Thanks to:
		     Sam Rowlands with the Mac declares
		     Axel Schneider with Linux locations
		
		Usage:
		     To access "Copy Files" build step locations:
		         TPSF.AppParent
		         TPSF.BundleParent
		         TPSF.Contents
		         TPSF.Frameworks
		         TPSF.Resources
		
		
		     Direct access to your own Application Support Folder:
		         TPSF.AppSupport
		
		     This will return a FolderItem with the path:
		           Mac: ~/Library/Application Support/[bundle identifier]
		           Win: \Users\[user]\AppData\Roaming\[app name]
		         Linux: /home/UserName/.[app name]
		
		
		     To get your app's Bundle Identifier via proper Cocoa declares:
		         App.BundleIdentifier
	#tag EndNote


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
