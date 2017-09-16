package manager
{
	import com.kv.KvFile;
	
	import data.GbData;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.core.FlexGlobals;

	/**
	 * @author 62344
	 */	
	public class ProjectManager
	{
		public static var kvFile:KvFile;
		
		public static function init():void
		{
			var file:File = new File(File.applicationStorageDirectory.nativePath+"/config.kv");
			FlexGlobals.topLevelApplication.addLog("访问程序存储文件目录："+file.nativePath);
			if(file.exists)//文件如果存在,则直接加载读取文件所在的路径
			{
				setProjectPath(null);
			}
			else//文件如果不存在,则选择文件路径并创建
			{
				OptionMgr.choosePath();
			}
		}
		
		/**
		 * 选择数据目录
		 * @param evt
		 */		
		public static function choosePath(evt:Event):void
		{
			var file:File = evt.target as File;
			file.removeEventListener(Event.SELECT,ProjectManager.choosePath);
			setProjectPath(file.nativePath);
		}
		
		/**
		 * 设置项目路径
		 * @param url
		 */		
		private static function setProjectPath(url:String):void
		{
			kvFile = new KvFile(File.applicationStorageDirectory.nativePath+"/config.kv");
			if(url==null)
				kvFile.loadValues();
			else
				kvFile.setValue("url",url);
			GbData.fileUrl = kvFile.getValue("url");
			FlexGlobals.topLevelApplication.addLog("将数据文件所在位置设置到:"+GbData.fileUrl);
			FlexGlobals.topLevelApplication.initFileList();
		}
	}
}