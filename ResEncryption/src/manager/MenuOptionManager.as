package manager
{
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import mx.core.FlexGlobals;
	import mx.styles.StyleManager;

	/**
	 * 修改工具导航
	 * @author 62344
	 */	
	public class MenuOptionManager
	{
		private static var _nativeMenu:NativeMenu;
		
		/**初始化按钮*/		
		public static function init():void
		{
			StyleManager.getStyleManager(null).getStyleDeclaration('mx.controls.ToolTip').setStyle('fontSize',12); 
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,loadComplete)
			loader.load(new URLRequest("resource/xml/menu.xml"));
		}
		
		/**配置文件加载完成*/
		private static function loadComplete(evt:Event):void
		{
			var xml:XML = XML(evt.target.data);
			var xmlList:XMLList = xml.menu;
			//创建主菜单
			var mainMenu:NativeMenu = new NativeMenu();
			
			for(var i:int = 0;i < xmlList.length();i++)
			{
				//创建第一级菜单
				var baseMenu:NativeMenu = new NativeMenu();
				var menuArr:Array = [];
				var menuXml:XML = xmlList[i];
				var itemList:XMLList = menuXml.item;
				
				for(var j:int=0;j<itemList.length();j++)
				{
					var _name:String = itemList[j].@name;
					var itemMenu:NativeMenuItem;
					var _checkid:String = itemList[j].@checked;
					//如果名字为空，则创建分隔符
					if(_name == "")
					{
						itemMenu = new NativeMenuItem(_name,true);
					}
					else
					{
						itemMenu = new NativeMenuItem(_name);
						itemMenu.data = itemList[j];
						var _key:String = itemList[j].@key;
						if(_key != "")
						{
							itemMenu.keyEquivalent = _key;
						}
						itemMenu.addEventListener(Event.SELECT,OptionMgr.selectMenu);
					}
					if(_checkid == "true")
					{
						itemMenu.checked = true;
					}
					menuArr.push(itemMenu);
				}
				baseMenu.items = menuArr;
				mainMenu.addSubmenu(baseMenu,menuXml.@name);
			}
			//设置菜单
			_nativeMenu = FlexGlobals.topLevelApplication.nativeWindow.menu = mainMenu;
		}
	}
}