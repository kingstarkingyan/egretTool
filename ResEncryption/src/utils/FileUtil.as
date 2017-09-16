package utils
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	/**
	 * 文件
	 * @author 62344
	 */	
	public class FileUtil extends File
	{
		private var _handler:Function;
		
		public function FileUtil(path:String=null)
		{
			super(path);
		}
		
		/**
		 * 将对象写为JSON
		 * @param obj
		 * @param callHandler
		 */		
		public function saveAsJson(obj:*,callHandler:Function):void
		{
			var str:String = JSON.stringify(obj);
			_handler = callHandler;
			var fileStream:FileStream = new FileStream();
			fileStream.open(this,FileMode.WRITE);
			fileStream.writeUTFBytes(str);
			fileStream.close();
			if(_handler!=null)
				_handler();
			_handler = null;
		}
		
		/**
		 * 写字节
		 * @param bytes
		 */		
		public function saveBytes(bytes:ByteArray):void
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open(this,FileMode.WRITE);
			fileStream.writeBytes(bytes);
			fileStream.close();
		}
		
		/**
		 * 写文本
		 * @param str
		 */		
		public function saveTxt(str:String):void
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open(this,FileMode.WRITE);
			fileStream.writeUTFBytes(str);
			fileStream.close();
		}
	}
}