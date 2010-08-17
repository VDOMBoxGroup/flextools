package view
{


import flash.display.DisplayObject;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.filters.DropShadowFilter;

import org.aswing.AssetIcon;
import org.aswing.BorderLayout;
import org.aswing.EmptyLayout;
import org.aswing.FlowLayout;
import org.aswing.Insets;
import org.aswing.JButton;
import org.aswing.JComboBox;
import org.aswing.JFrame;
import org.aswing.JLabel;
import org.aswing.JPanel;
import org.aswing.JPopupMenu;
import org.aswing.JProgressBar;
import org.aswing.JScrollPane;
import org.aswing.JTextArea;
import org.aswing.border.EmptyBorder;
import org.aswing.geom.IntDimension;

/**
 * MyPane
 */
public class AppPanel extends JPanel
{

	//members
	private var ta:ScriptAreaComponent;

	public var lbl1:JLabel;
	
	public var btnSave:JButton;
	public var btnRestore:JButton;
	
	public var btnTestSWF:JButton;
	public var btnAbout:JButton;
	public var btnFile:JButton;
	
	public var progressBar:JProgressBar;

	[Embed(source="newWindow.png")]
	private var WindowIconAsset:Class;
	private var targetCmb:JComboBox;	
	
	/**
	 * MyPane Constructor
	 */
	public function AppPanel()
	{
		//component creation
		setSize(new IntDimension(300, 300));
		var border0:EmptyBorder = new EmptyBorder(null, new Insets(3,3,3,3));
		setBorder(border0);
		var layout2:BorderLayout = new BorderLayout();
		setLayout(layout2);

		//button list
		var pan:JPanel = new JPanel(new FlowLayout);
		
		btnSave = new JButton('Save TypeDB');
		//pan.append(btnSave);
		
		//btnRestore = new JButton('Restore TypeDB');
		//pan.append(btnRestore);
		
		//pan.append(new JSeparator(JSeparator.VERTICAL));
		
		
		btnFile = new JButton('Main.as');
		pan.append(btnFile);
		var menu:JPopupMenu = new JPopupMenu;
		menu.addMenuItem('Open file [Ctrl+O]').addActionListener(function():void {
			dispatchEvent(new Event('fileOpen'));
		});
		menu.addMenuItem('Save file [Ctrl+S]').addActionListener(function():void {
			dispatchEvent(new Event('fileSave'));
		});
		btnFile.addActionListener(function():void {
			menu.show(btnFile, 0, btnFile.height+2);
		});
		
		targetCmb = new JComboBox(['FlashPlayer 10','FlashPlayer 10 + ASwing']);
		targetCmb.setToolTipText('Choose Target');
		targetCmb.addActionListener(function():void {
			ExternalInterface.call('setPlayTarget', ['swf', 'aswing'][targetCmb.getSelectedIndex()]);
		});
		targetCmb.setSelectedIndex(0);
		targetCmb.setPreferredWidth(180);
		pan.append(targetCmb);
		
		pan.append(btnTestSWF = new JButton('Compile and Run'));
		btnTestSWF.setToolTipText('Compile and Run [F8]');
		
		pan.append(btnAbout = new JButton('About MiniBuilder'));
		
		var me:DisplayObject = root;
		btnAbout.addActionListener(function():void {
			var window:JFrame = new JFrame(me, 'About MiniBuilder');
			var sp:JScrollPane = new JScrollPane;
			var txt:JTextArea = new JTextArea();
			txt.setHtmlText(
				'<b>Created by Victor Dramba, 2009</b><br>' +
				'Version 0.0.2<br>' + 
				'MiniBuilder consists in:' +
				'<ul>' + 
				'<li>an ActionScript <b>code assist engine</b> ' + 
				'written in ActionScript</li>' + 
				'<li>and a simple ActionScript <b>compiler</b> ' + 
				'that can run in the web browser inside ' + 
				'a Java Applet</li></ul><br>' + 
				'The compiler is based on asc.jar, part of the open-source ' + 
				'<a href="http://opensource.adobe.com/"><b><u>Flex SDK</u></b></a>.\n' + 
				'The editor is based on <a href="http://www.aswing.org/"><b><u>ASWing</u></b></a> component framework ' + 
				'and uses <b>ScriptArea</b>, a custom component designed for editing source-code.<br><br>' +
				'<a href="http://www.victordramba.com/?page_id=32"><u><b>MiniBuilder Homepage</b></u></a>' 
				);
			txt.setWordWrap(true);
			txt.setEditable(false);
			sp.append(txt);
			window.getContentPane().append(sp);
			
			window.setSizeWH(380, 210);
			window.show();
			window.setLocationXY(69, 40);
			
			window.filters = [new DropShadowFilter(2, 45, 0, .3, 6, 6)];
		});
		
		
		
		//top right
		var toppan:JPanel = new JPanel(new BorderLayout);
		toppan.append(pan, BorderLayout.CENTER);
		
		
		pan = new JPanel(new EmptyLayout);
		pan.setSize(new IntDimension(200, 18));
		
		lbl1 = new JLabel('label');
		lbl1.setPreferredWidth(200);
		lbl1.setHorizontalAlignment(JLabel.RIGHT);
		lbl1.setSize(new IntDimension(173, 22));
		lbl1.setLocationXY(0, 3);
		pan.append(lbl1);
		
		progressBar = new JProgressBar;
		progressBar.setSize(new IntDimension(100, 12));
		progressBar.setLocationXY(75, 8);
		progressBar.visible = false;
		pan.append(progressBar);

		var nw:JButton = new JButton('', new AssetIcon(new WindowIconAsset));
		nw.setToolTipText('Open in new Window');
		nw.setLocationXY(178, 3);
		nw.pack();
		pan.append(nw);
		
		nw.addActionListener(function():void {
			ExternalInterface.call('openInPopup', ta.text);
		});

		
		toppan.append(pan, BorderLayout.EAST);
		append(toppan, BorderLayout.NORTH);
		
		var scrollpane:JScrollPane
		
		ta = new ScriptAreaComponent();
		scrollpane = new JScrollPane;
		scrollpane.append(ta);
		append(scrollpane);
	}

	public function get textarea():ScriptAreaComponent
	{
		return ta;
	}
	
	private var _fileName:String = 'Main.as';

	public function set fileName(value:String):void
	{
		_fileName = value;
		btnFile.setText(value);
		btnFile.pack();
		btnFile.getParent().revalidate();
	}
	
	public function get fileName():String
	{
		return _fileName;
	}
	
	public function setTarget(target:String):void
	{
		if (target == 'aswing')
		{
			targetCmb.setSelectedIndex(1);
			ExternalInterface.call('setPlayTarget', 'aswing');
		}
		else
		{
			targetCmb.setSelectedIndex(0);
			ExternalInterface.call('setPlayTarget', 'swf');
		}
	}
}
}
