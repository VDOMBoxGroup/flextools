package net.vdombox.powerpack.menu
{

import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Dictionary;

import mx.controls.FlexNativeMenu;
import mx.events.FlexNativeMenuEvent;

import net.vdombox.powerpack.lib.extendedapi.ui.SuperNativeMenu;
import net.vdombox.powerpack.lib.extendedapi.ui.SuperNativeMenuItem;
import net.vdombox.powerpack.lib.player.managers.ContextManager;
import net.vdombox.powerpack.lib.player.managers.LanguageManager;

public class MenuGeneral extends EventDispatcher
{
	public static const LANG_FOLDER	: String = "assets/lang";
	public static const STATE_NO	: String = "noTemplate";
	public static const STATE_NEW	: String = "newTemplate";
	public static const STATE_MOD	: String = "modifiedTemplate";
	public static const STATE_OPEN	: String = "openedTemplate";

	public static const MENU_FILE		: String = "file";
	public static const MENU_RUN		: String = "run";
	public static const MENU_TEMPLATE	: String = "template";
	
	[Bindable]
	public static var state : String;
	
	private static var _menu : FlexNativeMenu;
	private static var memMenu : Dictionary;

	public static function get menu():FlexNativeMenu
	{
		return _menu;
	}

	public static function set menu(value:FlexNativeMenu):void
	{
		_menu = value;
	}

	public static function bindItems() : void
	{
		bindItemsRecursive( MenuGeneral.menu.nativeMenu );
	}

	private static function bindItemsRecursive( menu : NativeMenu ) : void
	{
		for each ( var item : NativeMenuItem in menu.items )
		{
			LanguageManager.bindSentence( 'menu_' + item.name, item, 'mnemonicLabel' );

			if ( item.submenu )
				bindItemsRecursive( item.submenu );
		}
	}

	public static function enable() : void
	{
		if ( memMenu )
		{
			for each( var item : NativeMenuItem in menu.nativeMenu.items )
				item.enabled = memMenu[item];
		}
		else
		{
			for each( item in menu.nativeMenu.items )
				item.enabled = true;
		}
	}

	public static function disable() : void
	{
		memMenu = new Dictionary( true );

		for each( var item : NativeMenuItem in menu.nativeMenu.items )
			memMenu[item] = item.enabled;
	}

	public static function noTemplate() : void
	{
		state = STATE_NO;

		// process file menu
		updateFileSubMenuState(false);
		
		// process template menu
		updateMenuState(MENU_TEMPLATE, false);
		
		// process run menu
		updateMenuState(MENU_RUN, false);
	}

	public static function newTemplate() : void
	{
		state = STATE_NEW;

		// process file menu
		updateFileSubMenuState(true);
		
		// process template menu
		updateMenuState(MENU_TEMPLATE, true);
		
		// process run menu
		enableDebugStartMenu();
	}
	
	public static function modifiedTemplate() : void
	{
		state = STATE_MOD;

		// process file menu
		updateFileSubMenuState(true);
		
		// process template menu
		updateMenuState(MENU_TEMPLATE, true);
		
		// process run menu
		enableDebugStartMenu();
	}

	public static function openedTemplate() : void
	{
		state = STATE_OPEN;

		// process file menu
		updateFileSubMenuState(true, false);
		
		// process template menu
		updateMenuState(MENU_TEMPLATE, true);

		// process run menu
		enableDebugStartMenu();
	}

	public static function updateLangMenu() : void
	{
		// get language folder
		var langsDir : File = File.applicationDirectory.resolvePath( LANG_FOLDER );

		if ( langsDir.exists )
		{
			var fileList : Array = langsDir.getDirectoryListing();

			var settingsItem : NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName( "settings" );
			var langItem : NativeMenuItem = settingsItem.submenu.getItemByName( "language" );

			if ( langItem.submenu )
				langItem.submenu.removeAllItems();
			else
			{
				langItem.submenu = new SuperNativeMenu();
				langItem.submenu.addEventListener( Event.SELECT, selectMenu_01 );

				function selectMenu_01( event : Event ) : void
				{
					var item : SuperNativeMenuItem = event.target as SuperNativeMenuItem;
					var clickEvent : FlexNativeMenuEvent = new FlexNativeMenuEvent(
							FlexNativeMenuEvent.ITEM_CLICK,
							false,
							false,
							item.menu,
							item,
							item.data,
							item.label,
							item.menu.getItemIndex( item ) );

					MenuGeneral.menu.dispatchEvent( clickEvent );
				}
			}

			// get language files
			for ( var i : int = 0; i < fileList.length; i++ )
			{
				var fileStream : FileStream = new FileStream();
				fileStream.open( fileList[i], FileMode.READ );

				var langXML : XML = XML( fileStream.readUTFBytes( fileStream.bytesAvailable ) );
				fileStream.close();

				if ( langXML.name() != "language" || !langXML.@id.toString() || !langXML.@label.toString() )
					continue;

				var item : SuperNativeMenuItem = new SuperNativeMenuItem(
						"radio",
						langXML.@label,
						langXML.@id,
						false,
						"language",
						true,
						true );

				item.data = fileList[i].name;

				if ( ContextManager.instance.lang.label.toLowerCase() == langXML.@label.toLowerCase() )
				{
					ContextManager.instance.lang.file = fileList[i].name
					item.checked = true;
				}

				langItem.submenu.addItem( item );
			}

			if ( langItem.submenu.numItems == 0 )
				langItem.enabled = false;
			else
				langItem.enabled = true;
		}
	}

	public static function updateLastFilesMenu() : void
	{
		if ( ContextManager.instance.files && ContextManager.instance.files.length > 0 )
		{
			if (!MenuGeneral.menu)
				return;
			
			var fileItem : NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName( "file" );
			var exitItem : NativeMenuItem = fileItem.submenu.getItemByName( "exit" );

			for each( var item : SuperNativeMenuItem in fileItem.submenu.items )
			{
				if ( item.groupName == 'lastfiles' )
					item.menu.removeItem( item );
			}

			for ( var i : int = 0; i < ContextManager.instance.files.length; i++ )
			{
				var label : String = (i + 1) + " " + (ContextManager.instance.files[i] as File).name +
						" [" + (ContextManager.instance.files[i] as File).parent.nativePath + "]";

				item = new SuperNativeMenuItem(
						"normal",
						label,
						"lastfile" + i,
						false,
						"lastfiles" );

				item.data = (ContextManager.instance.files[i] as File).nativePath;

				fileItem.submenu.addItemAt( item, exitItem.menu.getItemIndex( exitItem ) );

				item.addEventListener( Event.SELECT, selectMenuItem_01 );

				function selectMenuItem_01( event : Event ) : void
				{
					var item : SuperNativeMenuItem = event.target as SuperNativeMenuItem;
					var clickEvent : FlexNativeMenuEvent = new FlexNativeMenuEvent(
							FlexNativeMenuEvent.ITEM_CLICK,
							false,
							false,
							item.menu,
							item,
							item.data,
							item.label,
							item.menu.getItemIndex( item ) );

					MenuGeneral.menu.dispatchEvent( clickEvent );
				}
			}

			item = new SuperNativeMenuItem(
					"separator",
					"",
					"lastfile",
					false,
					"lastfiles" );

			fileItem.submenu.addItemAt( item, exitItem.menu.getItemIndex( exitItem ) );
		}
	}
	
	public static function updateMenuState (menuType : String, enabled : Boolean) : void 
	{
		return;
//		if ( !MenuGeneral.menu)
//			return;
		
		var menuItem : NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName( menuType );
		menuItem.enabled = enabled;
		
		for each ( var subItem : NativeMenuItem in menuItem.submenu.items )
		{
			subItem.enabled = enabled;
		}
	}
	
	private static function enableDebugStartMenu () : void 
	{
		var runItem : NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName( "run" );
		runItem.enabled = true;
		
		for each ( var item : NativeMenuItem in runItem.submenu.items )
		{
			item.enabled = false;
		}
		
		runItem.submenu.getItemByName( "run" ).enabled = true;
		runItem.submenu.getItemByName( "debug" ).enabled = true;
		runItem.submenu.getItemByName( "step_by_step" ).enabled = true;
	}
	
	public static function updateFileSubMenuState (enabled : Boolean, tplFileModified : Boolean = true) : void 
	{
		var fileMenu : NativeMenu = MenuGeneral.menu.nativeMenu.getItemByName( "file" ).submenu;
		
		fileMenu.getItemByName( "new_category" ).enabled = enabled;
		fileMenu.getItemByName( "close" ).enabled = enabled;
		fileMenu.getItemByName( "save_as" ).enabled = enabled;
		
		fileMenu.getItemByName( "save" ).enabled = enabled ? tplFileModified : enabled;
	}
	
}
}