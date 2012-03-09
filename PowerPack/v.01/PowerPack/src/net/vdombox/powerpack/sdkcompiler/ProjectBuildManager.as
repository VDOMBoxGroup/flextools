package net.vdombox.powerpack.sdkcompiler
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import net.vdombox.powerpack.lib.player.managers.ContextManager;
	import net.vdombox.powerpack.lib.player.popup.AlertPopup;
	import net.vdombox.powerpack.lib.player.template.VDOMApplication;
	import net.vdombox.powerpack.managers.ProgressManager;
	import net.vdombox.powerpack.template.BuilderTemplate;
	import net.vdombox.powerpack.template.BuilderTemplateProject;
	
	public class ProjectBuildManager extends EventDispatcher
	{
		private static var _instance : ProjectBuildManager;
		
		private var shObject : SharedObject = SharedObject.getLocal( "air_properties" );
		
		
		public function ProjectBuildManager()
		{
			super();
			
			if (_instance)
				throw Error("Only one instance of ProjectBuildManager can be declared");
			
		}
		
		public static function getInstance() : ProjectBuildManager
		{
			if ( !_instance )
			{
				_instance = new ProjectBuildManager();
			}
			
			return _instance;
		}
		
		
		public function exportProjectBuild () : void
		{
			saveTemplate ();
		}
		
		public function get currentTemplate() : BuilderTemplate
		{
			if ( !ContextManager.templates || ContextManager.templates.length == 0 )
				return null;
			
			return ContextManager.templates.getItemAt( 0 ) as BuilderTemplate;
		}
		
		private function saveTemplate () : void
		{ 
			if (!currentTemplate)
			{
				AlertPopup.show("No opened template", "Error", AlertPopup.OK, _dialog);
				return;
			}
			
			currentTemplate.addEventListener( Event.COMPLETE, templateSaveCompleteHandler );
			currentTemplate.addEventListener( ErrorEvent.ERROR, templateSaveErrorHandler );
			
			currentTemplate.save();
			
			function templateSaveCompleteHandler(evt:Event) : void
			{
				currentTemplate.removeEventListener( Event.COMPLETE, templateSaveCompleteHandler );
				
				try
				{
					var tplTargetFile : File = File.applicationStorageDirectory.resolvePath("assets/template.xml");
					currentTemplate.file.copyTo(tplTargetFile, true);
				}
				catch (e:Error)
				{
					AlertPopup.show("Can't save template", "Error", AlertPopup.OK, _dialog);
					return;
				}
				
				buildInstaller();
			}
			
			function templateSaveErrorHandler(evt:Event) : void
			{
				currentTemplate.removeEventListener( ErrorEvent.ERROR, templateSaveErrorHandler );
				
				AlertPopup.show("Can't save template", "Error", AlertPopup.OK, _dialog);
			}
		}
		
		private function buildInstaller():void
		{
			var installerPropertiesXmlPrepeared : Boolean = prepareInstallerPropertiesXml();
			
			var app : VDOMApplication = new VDOMApplication();
			app.stored = prepareInstallerApp();
			app.path = BuilderTemplateProject(currentTemplate.selectedProject).embededAppPath;
			
			if (!installerPropertiesXmlPrepeared)
			{
				AlertPopup.show("Can't prepare installer properties xml", "Error", AlertPopup.OK, _dialog);
				return;
			}
			
			var sdkCompiler : SDKCompiler = SDKCompilerCreator.create();
			
			if (!sdkCompiler.hasEventListener(SDKCompilerEvent.SDK_COMPILER_COMPETE))
				sdkCompiler.addEventListener(SDKCompilerEvent.SDK_COMPILER_COMPETE, sdkCompilerEventHandler); 
			
			if (!sdkCompiler.hasEventListener(SDKCompilerEvent.SDK_COMPILER_ERROR))
				sdkCompiler.addEventListener(SDKCompilerEvent.SDK_COMPILER_ERROR, sdkCompilerEventHandler);
			
			ProgressManager.complete();
			ProgressManager.source = null;
			ProgressManager.start( ProgressManager.DIALOG_MODE, false );
			
			sdkCompiler.buildInstallerPackage ( BuilderTemplateProject(currentTemplate.selectedProject).outputFolderPath, 
				BuilderTemplateProject(currentTemplate.selectedProject).outputFileName, 
				app, 
				flexSDK_4_1_BrowseBox.path,
				airSDKLinuxBrowseBox.path,
				radioBtnGroupBuildType.selectedValue.toString());
			
			function sdkCompilerEventHandler (evt:SDKCompilerEvent) : void
			{
				sdkCompiler.removeEventListener(SDKCompilerEvent.SDK_COMPILER_COMPETE, sdkCompilerEventHandler);
				sdkCompiler.removeEventListener(SDKCompilerEvent.SDK_COMPILER_ERROR, sdkCompilerEventHandler);
				
				ProgressManager.complete();
				
				if (evt.message)
				{
					AlertPopup.show(evt.message,"", OK, _dialog);
				}
			}
		}
		
	}
}