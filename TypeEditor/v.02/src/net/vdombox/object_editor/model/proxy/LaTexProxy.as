package net.vdombox.object_editor.model.proxy
{
	import flash.events.TimerEvent;
    import flash.filesystem.File;
import flash.net.SharedObject;
import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.Operation;
	
	import net.vdombox.object_editor.event.SOAPErrorEvent;
	import net.vdombox.object_editor.event.SOAPEvent;
	import net.vdombox.object_editor.model.bisiness.SOAP;
    import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
    import net.vdombox.object_editor.model.vo.AuthInfoVO;
	import net.vdombox.object_editor.model.vo.ConnectInfoVO;
	import net.vdombox.object_editor.model.vo.ErrorVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;

	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class LaTexProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "LaTexProxy";

		public function LaTexProxy()
		{
			super( NAME );
		}

        private var shObject : SharedObject;

        private var _typesDocPath : String = "";

        public function get typesDocPath():String {
            return _typesDocPath;
        }

        public function set typesDocPath(value:String):void
        {
            if (value == _typesDocPath)
                return;

            _typesDocPath = value;

            shObject.data["types_doc_path"] = value;

            sendNotification( ApplicationFacade.TYPES_DOC_PATH_CHANGED, _typesDocPath );
        }

        override public function onRegister():void {
            super.onRegister();

            shObject = SharedObject.getLocal( "doc_settings" );

            if (shObject.data.hasOwnProperty("types_doc_path"))
                _typesDocPath = shObject.data["types_doc_path"] ;

        }

        public function getTypeAttributesPaths ( typeLaTexContent : String ) : Array
        {
            var startIndex : int = typeLaTexContent.indexOf("\subsection{Attributes}");
            var attrSection : String = typeLaTexContent.substring(startIndex);

            var attributesRelatedPaths : Array = attrSection.split("\n");

            if (!attributesRelatedPaths || attributesRelatedPaths.length < 1)
                return null;

            attributesRelatedPaths = attributesRelatedPaths.slice(1);

            var attributesNativePaths : Array = [];
            for each (var attrRelatedPath : String in attributesRelatedPaths)
            {
				if (!attrRelatedPath)
					break;
				
                attrRelatedPath = attrRelatedPath.substring(attrRelatedPath.indexOf("{")+1, attrRelatedPath.indexOf("}"));
                attrRelatedPath = attrRelatedPath.substring(5); // remove "types/" from the beginning

                var attrNativePath : String = typesDocPath + attrRelatedPath + ".tex";

                attributesNativePaths.push( fileProxy.getCorrectFilePath(attrNativePath) );
            }

            return attributesNativePaths;
        }

        public function getAttributeDescription (attributeLaTexContent : String) : String
        {
            if (!attributeLaTexContent)
                return "";

            var texParagraphs : Array = attributeLaTexContent.split("\n");

            if (!texParagraphs || texParagraphs.length < 2)
                return "";

            var description : String = texParagraphs[1];

            if (texParagraphs.length < 3)
                return description;

            var paragraph : String = "";
            for (var i:int=2; i<texParagraphs.length; i++)
            {
                paragraph = texParagraphs[i];
                paragraph = paragraph.replace("\r", "");
                if (paragraph == "")
                    break;

                description += "\n" + texParagraphs[i];
            }

            description = convertBoldText(description);
            description = convertExpression(description, / --- /g, ' - ');                   // ' --- ' -> ' - '
            description = convertExpression(description, /\\textless[ ]{0,1}/g, '<');     //  '\textless ' -> '&lt;'
            description = convertExpression(description, /[ ]{0,1}\\textgreater/g, '>');  //  ' \textgreater' -> '&gt;'
            description = convertExpression(description, /\\#/g, '#');                       // '\#' -> '#'
            description = convertExpression(description, /\\_/g, "_");                       // '\_' -> '_'

            description = convertExpression(description, /^%.*$\n/mg, '');                      // '%Text\n' -> ''
            description = convertExpression(description, /%.*$/mg, '');                      // 'Text %Comment' -> 'Text'

//            description = convertExpression(description, /\n/g, '<br/>');

            return description;
        }

        public function getAttributeName (attributeLaTexContent : String) : String
        {
            if (!attributeLaTexContent)
                return "";

            var texParagraphs : Array = attributeLaTexContent.split("\n");

            if (!texParagraphs || texParagraphs.length < 1)
                return "";

            var attrName : String = texParagraphs[texParagraphs.length-1];

            attrName = convertExpression(attrName, /\\#/g, '#');                       // '\#' -> '#'
            attrName = convertExpression(attrName, /\\_/g, "_");                       // '\_' -> '_'
            attrName = convertExpression(attrName, /^%.*$\n/mg, '');                      // '%Text\n' -> ''
            attrName = convertExpression(attrName, /%.*$/mg, '');                      // 'Text %Comment' -> 'Text'

            return attrName;
        }


        private function convertBoldText (source : String) : String
        {
            if (!source)
                return "";

            var boldCommandRegExp : RegExp = /\\textbf\{[^\{]*\}/g;

            var boldCommands : Array = source.match(boldCommandRegExp);

            if (!boldCommands || boldCommands.length < 1)
                return source;

            var result : String = source;
            for each (var boldCommand : String in boldCommands)
            {
                var boldTag : String = "'"+boldCommand.substring(8,boldCommand.length-1)+"'"
                result = result.replace(boldCommand, boldTag);
            }

            return result;
        }

        private function convertExpression (source : String, pattern : RegExp, repl : String) : String
        {
            if (!source)
                return "";

            return source.replace(pattern, repl);
        }

        public function isCorrectTypesDocPath (folder_path : String) : Boolean
        {
            if (!folder_path)
                return true;

            var docFolderContent : Array = fileProxy.getFolderContent(folder_path);

            if (!docFolderContent)
                return false;

            var typesFolder : File;
            for each (var file:File in docFolderContent)
            {
                if (file.isDirectory && file.exists && file.name == "type")
                {
                    typesFolder = file;
                    break;
                }
            }

            if (!typesFolder)
                return false;

            var typesLaTexFiles : Array = fileProxy.filterLaTexFiles(typesFolder.getDirectoryListing());

            if (!typesLaTexFiles || typesLaTexFiles.length < 1)
                return false;

            return true;
        }

        private function get fileProxy () : FileProxy
        {
            return facade.retrieveProxy(FileProxy.NAME) as FileProxy;
        }


    }
}