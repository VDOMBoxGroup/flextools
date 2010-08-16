/*
 * @Author Dramba Victor
 * 2009
 * 
 * You may use this code any way you like, but please keep this notice in
 * The code is provided "as is" without warranty of any kind.
 */

package 
{
	import com.victordramba.console.Debugger;
	import com.victordramba.console.debug;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	
	import mx.core.ByteArrayAsset;
	
	import org.aswing.ASFont;
	import org.aswing.AsWingManager;
	import org.aswing.JWindow;
	import org.aswing.UIManager;
	import org.aswing.geom.IntDimension;
	import org.aswing.skinbuilder.orange.OrangeLookAndFeel;
	
	import ro.victordramba.asparser.Controller;
	
	import view.AppPanel;
	import view.ScriptAreaComponent;

	[SWF(backgroundColor="#ffffbb")]
	[Frame(factoryClass="Preloader")]

	
	public class CodeAssist extends Sprite
	{

		[Embed(source="swfExample.as", mimeType="application/octet-stream")]
		//[Embed(source="example.as", mimeType="application/octet-stream")]
		private var SrcAsset:Class;
		
		private var ctrl:Controller;
		
		private var fld:ScriptAreaComponent;

		//public function CodeAssist()
		public function init():void
		{
			stage.align = 'TL';
			stage.scaleMode = 'noScale';

			//Debugger console
//			Debugger.setParent(stage);
			
			UIManager.setLookAndFeel(new OrangeLookAndFeel);
			AsWingManager.initAsStandard(this);


			//var frame : JFrame = new JFrame( this, "Code Assist" );
			var frame :JWindow = new JWindow(this);
			var panel:AppPanel = new AppPanel;
			frame.getContentPane().append(panel);
			frame.setSize(new IntDimension( 200, 120 ) );
			//frame.setClosable(false);
			frame.show();
			//frame.setState(JFrame.MAXIMIZED);
			
			stage.addEventListener(Event.RESIZE, function(e:Event):void {
				frame.setSizeWH(stage.stageWidth, stage.stageHeight);
			});
			frame.setSizeWH(stage.stageWidth, stage.stageHeight);


			var fnt:ASFont;
			if (/linux/i.test(Capabilities.os))
				fnt = new ASFont('Liberation Mono');
			else
				fnt = new ASFont('Courier New');
			panel.textarea.setFont(fnt);

			var tf:TextFormat = new TextFormat;
			tf.size = 14;
			var a:Array = [];
			for (var i:uint=1; i<50; i++)
				a.push(i * 30);
			tf.tabStops = a;

			//var fld:TextField = panel.textarea.getTextField();
			fld = panel.textarea;
			ctrl = new Controller(stage, panel.textarea);
			

			//fld.defaultTextFormat = tf;
			//try to get source string from javascript
			var str:String = 'loading...';
			panel.textarea.text = str;
			
			if (stage.loaderInfo.parameters.srcURL)
			{
				var ld:URLLoader = new URLLoader;
				ld.addEventListener(Event.COMPLETE, function (e:Event):void {
					str = ld.data;
					panel.textarea.text = str.replace(/\n/g, '\r');
					ctrl.sourceChanged(fld.text);
					//default aswing target
					if (/import org.aswing/.test(str))
						panel.setTarget('aswing');
				});
				ld.load(new URLRequest(stage.loaderInfo.parameters.srcURL));
			}
			else
			{
				try {
					str = ExternalInterface.call('getSource');
				} catch (e:Error) {
					debug(e.getStackTrace());
				}
				
				if (!str)
				{
					var ba:ByteArrayAsset = new SrcAsset;
					str = ba.readUTFBytes(ba.length);
				}
				panel.textarea.text = str.replace(/\n/g, '\r');
				ctrl.sourceChanged(fld.text);
			}
			
			
			var codeAssist:MenuHelper = new MenuHelper(fld, ctrl, stage);

			
			ctrl.addEventListener('status', function(e:Event):void
			{
				panel.lbl1.setText(ctrl.status);
				panel.progressBar.setValue(ctrl.percentReady*100);
				panel.progressBar.visible = ctrl.percentReady < 1;
			});
			
			ctrl.addEventListener(Event.CHANGE, function(e:Event):void
			{
				//panel.getList1().setListData(ctrl.typeOptions);
				//panel.getList2().setListData(ctrl.typeInfo);
			});

			panel.btnSave.addEventListener(MouseEvent.CLICK, function(e:Event):void
			{
				ctrl.saveTypeDB();
			});
			/*panel.btnRestore.addEventListener(MouseEvent.CLICK, function(e:Event):void
			{
				ctrl.restoreTypeDB();
				ctrl.sourceChanged(fld.text);
			});*/
			
			/*panel.btnFileSave.addEventListener(MouseEvent.CLICK, function(e:Event):void
			{
				var so:SharedObject = SharedObject.getLocal('ascc');
				so.data.text = fld.text;
				so.flush();
			});
			
			panel.btnFileRestore.addEventListener(MouseEvent.CLICK, function(e:Event):void
			{
				var so:SharedObject = SharedObject.getLocal('ascc');
				fld.text = so.data.text;
				
				var txt:String = so.data.text;
				txt = txt.replace(/\/\/.*$/mg, '');
				txt = txt.replace(/\/\*\*.*?\*\//sg, '');
				txt = txt.replace(/\s+$/mg, '');
				txt = txt.replace(/\r+/sg, '\r');
				fld.text = txt;
				
				ctrl.sourceChanged(fld.text);
			});*/
			
			panel.btnTestSWF.addActionListener(function():void
			{
				ExternalInterface.call('compileCode', fld.text);
			});
			
			panel.addEventListener('fileSave', saveFile); 
			
			function saveFile(e:Event=null):void 
			{
				var file:FileReference = new FileReference;
				var ba:ByteArray = new ByteArray;
				ba[0]=239; ba[1]=187; ba[2]=191;
				ba.position = 3;
				ba.writeUTFBytes(fld.text);
				file.save(ba, panel.fileName);
				file.addEventListener(Event.SELECT, function(e:Event):void {
					panel.fileName = file.name;
				});
			}
			
			panel.addEventListener('fileOpen', openFile);
			
			function openFile(e:Event=null):void 
			{
				var file:FileReference = new FileReference;
				file.browse([new FileFilter('*.as', '*.as')]);
				file.addEventListener(Event.SELECT, function (e:Event):void {
					file.load();
				});
				file.addEventListener(Event.COMPLETE, function (e:Event):void {
					if (file.data[0]==239 && file.data[1]==187 && file.data[2]==191)
						file.data.position = 3;
					fld.text = file.data.readUTFBytes(file.data.bytesAvailable);
					ctrl.sourceChanged(fld.text);
				});
			}
			
			addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
				if (e.keyCode == Keyboard.F8)
					ExternalInterface.call('compileCode', fld.text);
				else if (e.ctrlKey && String.fromCharCode(e.charCode) == 's')
					saveFile();
				else if (e.ctrlKey && String.fromCharCode(e.charCode) == 'o')
					openFile();
			});
			
			ExternalInterface.addCallback('hintErrors', hintErrors);

		}
		
		private function hintErrors(lines:Array, errors:Array):void
		{
			fld.markLines(lines, errors);
		}
	}
}
