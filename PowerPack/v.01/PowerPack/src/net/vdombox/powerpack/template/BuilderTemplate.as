package net.vdombox.powerpack.template
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.utils.UIDUtil;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.FileToBase64;
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	import net.vdombox.powerpack.lib.player.managers.ContextManager;
	import net.vdombox.powerpack.lib.player.managers.LanguageManager;
	import net.vdombox.powerpack.lib.player.template.Template;
	import net.vdombox.powerpack.lib.player.template.TemplateProject;
	import net.vdombox.powerpack.managers.BuilderContextManager;
	import net.vdombox.powerpack.managers.CashManager;
	import net.vdombox.powerpack.managers.ProgressManager;
	
	public class BuilderTemplate extends Template
	{
		private static const BROWSE_TYPE_OPEN : String = "browseForOpen";
		private static const BROWSE_TYPE_SAVE : String = "browseForSave";
		private static const BROWSE_TYPE_NONE : String = "browseNone";
		
		private var browseType : String = BROWSE_TYPE_NONE;
		
		private var fileStream : FileStream = new FileStream();
		
		[Bindable]
		public var file : File;

		
		public function BuilderTemplate(xml:XML=null)
		{
			super(xml);
		}
		
		
		//----------------------------------
		//  fullID
		//----------------------------------
		
		private var _fullID : String;
		
		public function get fullID() : String
		{
			if ( !_fullID )
			{
				_fullID = ID;
				
				if ( file && file.exists )
					_fullID += '_' + file.creationDate.getTime() + '_' + file.modificationDate.getTime() + '_' + file.size;
			}
			
			return _fullID;
		}
		
		//---------------------------------------------------------
		override public function set modified( value : Boolean ) : void
		{
			if ( _modified != value )
			{
				_modified = value;
				
				var mainIndex : XML = CashManager.getMainIndex();
				
				CashManager.updateMainIndexEntry( mainIndex, fullID, 'saved', _modified ? 'false' : 'true' );
				CashManager.setMainIndex( mainIndex );
			}
		}
		
		[Bindable]
		override public function get modified() : Boolean
		{
			return super.modified;
		}
				
		override protected function clearOldProjectVariant () : void
		{
			super.clearOldProjectVariant();
			
			if (!xml) return;
			
			delete xml.appPath;
			delete xml.outputFolder;
			delete xml.outputFileName;
		}
		
		//---------------------------------------------------------
		//---------------------------------------------------------
		
		public function save() : void
		{
			if ( !_completelyOpened )
				return;
			
			if ( !file )
			{
				browseForSave();
				return;
			}
			
			try
			{
				// update tpl UID
				_xml.@ID = UIDUtil.createUID();
				
				fillProjects();
				
				// cash template structure
				cashStructure();
				
				/// get resources from cash 
				fillFromCash();
				
				// set (+encrypt) structure and resources data
				encode();
				
				ProgressManager.source = fileStream;
				ProgressManager.start();
				
				fileStream.addEventListener( Event.COMPLETE, saveHandler );
				fileStream.addEventListener( OutputProgressEvent.OUTPUT_PROGRESS, fileStreamOutputProgressHandler );
				fileStream.addEventListener( IOErrorEvent.IO_ERROR, fileStreamIOErrorHandler );
				
				fileStream.openAsync( file, FileMode.WRITE );
				fileStream.writeUTFBytes( _xml.toXMLString() );
			}
			catch ( e : Error )
			{
				fileStream.removeEventListener( Event.COMPLETE, saveHandler );
				fileStream.removeEventListener( OutputProgressEvent.OUTPUT_PROGRESS, fileStreamOutputProgressHandler );
				fileStream.removeEventListener( IOErrorEvent.IO_ERROR, fileStreamIOErrorHandler );
				
				file.cancel();
				fileStream.close();
				
				ProgressManager.complete();
				
				showError(e.message);
			}
		}
		
		public function open() : void
		{
			if ( !file )
			{
				browseForOpen();
				return;
			}
			
			if ( !file.exists )
			{
				showError(LanguageManager.sentences['msg_file_not_exists']);
				return;
			}
			
			ProgressManager.source = fileStream;
			ProgressManager.start();
			
			fileStream.addEventListener( Event.COMPLETE, openHandler );
			fileStream.addEventListener( IOErrorEvent.IO_ERROR, fileStreamIOErrorHandler );
			
			fileStream.openAsync( file, FileMode.READ );
		}
		
		public function browseForSave() : void
		{
			var folder : File = BuilderContextManager.instance.lastDir;
			
			folder.addEventListener( Event.SELECT, fileBrowseHandler );
			
			browseType = BROWSE_TYPE_SAVE;
			folder.browseForSave( LanguageManager.sentences['save_file'] );
		}
		
		public function browseForOpen() : void
		{
			var folder : File = BuilderContextManager.instance.lastDir;
			
			folder.addEventListener( Event.SELECT, fileBrowseHandler );
			
			browseType = BROWSE_TYPE_OPEN;
			folder.browseForOpen( LanguageManager.sentences['open_file'], [tplFilter, allFilter] )
		}
		
		private function cash() : Boolean
		{
			if ( _xmlStructure == null )
				return false;
			
			// cash all resources
			for each ( var res : XML in _xmlStructure.resources.resource )
			{
				CashManager.setStringObject( fullID,
					XML(
						"<resource " +
						"category='" + Utils.getStringOrDefault( res.@category, "" ) + "' " +
						"ID='" + Utils.getStringOrDefault( res.@ID, "" ) + "' " +
						"name='" + Utils.getStringOrDefault( res.@name, "" ) + "' " +
						"type='" + Utils.getStringOrDefault( res.@type, "" ) + "' />" ),
					res );
			}
			
			delete _xmlStructure.resources;
			
			cashStructure();
			
			return true;
		}
	
		private function cashStructure() : void
		{
			CashManager.setStringObject( fullID,
				XML(
					"<resource " +
					"category='template' " +
					"ID='template' " +
					"name='" + selectedProject.name + "' " +
					"type='" + TYPE_APPLICATION + "' />" ),
				_xml.toXMLString() );
			
			CashManager.setStringObject( fullID,
				XML(
					"<resource " +
					"category='template' " +
					"ID='structure' " +
					"name='" + selectedProject.name + "' " +
					"type='" + TYPE_APPLICATION + "' />" ),
				_xmlStructure.toXMLString() );
		}
		
		private function fillFromCash() : void
		{
			// get resources		
			delete _xmlStructure.resources;
			
			var index : XML = CashManager.getIndex( fullID );
			if ( index )
			{
				var resources : XMLList = index.resource.(hasOwnProperty( '@category' ) &&
					(@category == 'image' || @category == 'database'));
				
				_xmlStructure.appendChild( <resources/> );
				
				for each ( var res : XML in resources )
				{
					var resObj : Object = CashManager.getObject( fullID, res.@ID );
					var resData : ByteArray = ByteArray( resObj.data );
					var content : String = resData.readUTFBytes( resData.bytesAvailable );
					
					var resXML : XML = XML( '<resource><![CDATA[' + content + ']]></resource>' );
					resXML.@category = resObj.entry.@category;
					resXML.@ID = resObj.entry.@ID;
					resXML.@type = resObj.entry.@type;
					resXML.@name = resObj.entry.@name;
					
					_xmlStructure.resources.appendChild( resXML );
				}
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		private function fileBrowseHandler (event : Event) : void
		{
			var f : File = event.target as File;
			
			f.removeEventListener( Event.SELECT, fileBrowseHandler );
			
			if ( f.isDirectory || f.isPackage || f.isSymbolicLink )
			{
				browseType = BROWSE_TYPE_NONE;
				return;
			}
			
			switch (browseType)
			{
				case BROWSE_TYPE_OPEN:
				{
					browseType = BROWSE_TYPE_NONE;
					
					file = f;
					
					open();
					
					break;
				}
				case BROWSE_TYPE_SAVE:
				{
					browseType = BROWSE_TYPE_NONE;
					
					if ( !f.extension || f.extension.toLowerCase() != TPL_EXTENSION )
						f = f.parent.resolvePath( f.name + '.' + TPL_EXTENSION );
					
					file = f;
					
					save();
					
					break;
				}
				default:
				{
					browseType = BROWSE_TYPE_NONE;
					break;
				}
			}
		}
		
		private function fileStreamOutputProgressHandler( event : OutputProgressEvent ) : void
		{
			if ( event.bytesPending == 0 )
				fileStream.dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function saveHandler( event : Event ) : void
		{
			fileStream.removeEventListener( OutputProgressEvent.OUTPUT_PROGRESS, fileStreamOutputProgressHandler );
			fileStream.removeEventListener( Event.COMPLETE, saveHandler );
			fileStream.removeEventListener( IOErrorEvent.IO_ERROR, fileStreamIOErrorHandler );
			
			try
			{
				fileStream.close();
				
				ProgressManager.start( ProgressManager.DIALOG_MODE, false );
				
				xml = XML( CashManager.getStringObject( fullID, 'template' ) );
				
				// update tpl UID
				var oldID : String = fullID;
				_fullID = null;
				CashManager.updateID( oldID, fullID );
				
				ProgressManager.complete();
				
				modified = false;
				selectedProject.modified = false;
				
				dispatchEvent( new Event( Event.COMPLETE ) );
			}
			catch ( e : Error )
			{
				ProgressManager.complete();
				
				trace ("0");
				showError(LanguageManager.sentences['msg_not_valid_tpl_file']);
			}
		}
		
		private function openHandler( event : Event ) : void
		{
			fileStream.removeEventListener( Event.COMPLETE, openHandler );
			fileStream.removeEventListener( IOErrorEvent.IO_ERROR, fileStreamIOErrorHandler );
			
			try
			{
				ProgressManager.start( ProgressManager.DIALOG_MODE, false );
				
				var strData : String = fileStream.readUTFBytes( fileStream.bytesAvailable );
				fileStream.close();
				
				var xmlData : XML = XML( strData );
				
				if ( !isValidTpl( xmlData ) )
				{
					trace ("1");
					throw new Error( LanguageManager.sentences['msg_not_valid_tpl_file'] );
				}
				
				xml = xmlData;
				
				_completelyOpened = false;
				
				_fullID = null;
				
				processOpened();
				
				ProgressManager.complete();
				
				modified = false;
				
				dispatchEvent( new Event( Event.COMPLETE ) );
			}
			catch ( e : Error )
			{
				fileStream.close();
				
				ProgressManager.complete();
				
				trace ("2");
				showError(LanguageManager.sentences['msg_not_valid_tpl_file']);
			}
		}
		
		private function fileStreamIOErrorHandler( event : IOErrorEvent ) : void
		{
			browseType = BROWSE_TYPE_NONE;
			
			fileStream.removeEventListener( OutputProgressEvent.OUTPUT_PROGRESS, fileStreamOutputProgressHandler );
			
			fileStream.removeEventListener( Event.COMPLETE, saveHandler );
			fileStream.removeEventListener( Event.COMPLETE, openHandler );
			
			fileStream.removeEventListener( IOErrorEvent.IO_ERROR, fileStreamIOErrorHandler );
			
			file.cancel();
			fileStream.close();
			
			ProgressManager.complete();
			
			showError(event.text);
		}

		//-------------------------------------------------------
		override public function dispose() : void
		{
			super.dispose();
			
			file = null;
		}
		
		//-------------------------------------------------------
		//-------------------------------------------------------
		override public function processOpened() : void
		{
			super.processOpened();
			
			if ( _xmlStructure )
				cash();
		}
		
		//
		// projects 
		//
		
		override public function createNewProject () : TemplateProject
		{
			var newProject : BuilderTemplateProject = new BuilderTemplateProject();
			
			projects.addItem( newProject );
			
			modified = true;
			
			return newProject;
		}
		
		
	}
}