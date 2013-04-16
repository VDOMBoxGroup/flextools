package net.vdombox.powerpack.template
{
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.FileToBase64;
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	import net.vdombox.powerpack.lib.player.template.TemplateProject;
	import net.vdombox.powerpack.utils.GeneralUtils;
	
	public class BuilderTemplateProject extends TemplateProject
	{
		public static const DEFAULT_OUTPUT_FOLDER_PATH	: String = File.desktopDirectory.nativePath;
		public static const DEFAULT_OUTPUT_FILE_NAME	: String = "newProject";
		
		public function BuilderTemplateProject()
		{
			super();
		}
		
		//
		//	embededAppPath
		//
		private var _embededApps : Array;
		
		public function set embededApps( value : Array ) : void
		{
			if ( !GeneralUtils.equalArrays(embededApps, value) )
			{
				modified = true;
				_embededApps = value;
			}
		}
		
		[Bindable]
		public function get embededApps() : Array
		{
			return _embededApps;
		}
		
		
		//
		//	outputFileName
		//
		private var _outputFileName : String;
		
		public function set outputFileName( value : String ) : void
		{
			if (!value)
				value = DEFAULT_OUTPUT_FILE_NAME;
			
			if ( _outputFileName != value )
			{
				modified = true;
				_outputFileName = value;
			}
		}
		
		[Bindable]
		public function get outputFileName() : String
		{
			return Utils.getStringOrDefault( _outputFileName, DEFAULT_OUTPUT_FILE_NAME );
		}
		
		
		//
		//	outputFileName
		//
		private var shObject : SharedObject = SharedObject.getLocal( "project_settings" );
		
		private var _outputFolderPath : String;
		
		public function set outputFolderPath( value : String ) : void
		{
			if (!value)
				value = DEFAULT_OUTPUT_FOLDER_PATH;
			
			if ( _outputFolderPath != value )
			{
				modified = true;
				_outputFolderPath = value;
				shObject.data["output_folder_path"] = _outputFolderPath;
			}
		}
		
		[Bindable]
		public function get outputFolderPath() : String
		{
			var path : String = _outputFolderPath || shObject.data["output_folder_path"];
			
			return Utils.getStringOrDefault( path, DEFAULT_OUTPUT_FOLDER_PATH );
		}
		
		override public function toXML () : XML
		{
			var projectXML : XML = super.toXML();
			
			projectXML.appendChild(<outputFolderPath>{outputFolderPath}</outputFolderPath>);
			projectXML.appendChild(<outputFileName>{outputFileName}</outputFileName>);
			
			var embededAppsXml : XML = new XML("<embededApps/>");
			for each (var appPath:String in embededApps)
				embededAppsXml.appendChild(<embededAppPath>{appPath}</embededAppPath>);
			
			projectXML.appendChild(embededAppsXml);
			
			return projectXML;
		}
		
		override public function fillFromXML (projectXML : XML) : void
		{
			super.fillFromXML (projectXML);
			
			outputFolderPath	= projectXML.outputFolderPath;
			outputFileName		= projectXML.outputFileName;
			
			var appPath : String;
			embededApps=[];
			if (projectXML.embededApps.length() == 0)
			{
				appPath = projectXML.embededAppPath;
				if (appPath && appPath.length > 0)
					embededApps	= [appPath];
			}
			else
			{
				for each (var appPathXML : XML in projectXML.embededApps.embededAppPath)
				{	
					appPath = appPathXML.toString();
					if (!appPath)
						continue;
					
					embededApps.push(appPath);
				}
			}
			
			
		}
		
		override public function fillParamsFromEntireTemplateXML (xml : XML) : void 
		{
			super.fillParamsFromEntireTemplateXML(xml);
			
			outputFolderPath	= xml.outputFolder;
			outputFileName		= xml.outputFileName;
			
			embededApps			= [];
			var appPath : String = xml.appPath;
			if (appPath && appPath.length > 0)
				embededApps			= [appPath];
		}
		
		
	}
}