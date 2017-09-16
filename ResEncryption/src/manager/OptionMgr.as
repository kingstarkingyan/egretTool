package manager
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	
	/**
	 * 对应所有导航栏的点击操作
	 * @author Administrator 
	 */	
	public class OptionMgr
	{
		//当前点击的菜单XML信息
		private static var _clickMenuXml:XML;
		/**上一次操作*/
		private static var _id:String = "";
		//函数注册
		private static var _funDic:Dictionary;
		
		/**选择菜单*/
		public static function selectMenu(evt:Event):void
		{
			initFunDic();
			var xml:XML = XML(evt.target.data);
			_id = xml.@id;
			_clickMenuXml = xml;
			var str:String = xml.@fun;
			if(_funDic[str])
				(_funDic[str] as Function)();
		}
		
		/***/		
		private static function initFunDic():void
		{
			if(_funDic)
				return;
			_funDic = new Dictionary();
			_funDic["choosePath"] = choosePath;
		}
		
		/**选择目录*/		
		public static function choosePath():void
		{
			var _file:File = new File();
			_file.browseForDirectory("请选择数据(Excel)目录");
			_file.addEventListener(Event.SELECT,ProjectManager.choosePath);
		}
	}
}