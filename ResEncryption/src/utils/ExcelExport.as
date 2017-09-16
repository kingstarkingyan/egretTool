package utils
{
	import com.as3xls.xls.Sheet;
	
	import data.ExportData;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import manager.ProjectManager;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;

	/**
	 * Excel导出为可加载的数据
	 * @author yangyu
	 */
	public class ExcelExport
	{
		/**存储解析之后的字典,以表名为Key*/
		private var _dic:Dictionary;
		/**当前选择的path*/		
		private var _pathTarget:String;
		/**默认导出目录*/
		private var _selectPath:String;
		
		[Bindable]
		public var totalCount:int = 0;
		[Bindable]
		public var count:int = 0;
		
		public function ExcelExport()
		{
			_dic = new Dictionary(true);
		}
		
		/**
		 * 创建AS的类到指定的目录下
		 */		
		public function createCodeForAs():void
		{
			if(ProjectManager.kvFile.getValue("CODE_AS")!=null)
				Alert.show("是否导出到默认目录:"+ProjectManager.kvFile.getValue("CODE_AS"),"导出AS文件",Alert.YES|Alert.NO,null,forCodeAs);
			else
				selectPath("CODE_AS","选择AS文件导出目录");
		}
		
		/**创建egret的类文件*/
		public function createCodeForEgret():void
		{
			if(ProjectManager.kvFile.getValue("CODE_EGRET")!=null)
				Alert.show("是否导出到默认目录:"+ProjectManager.kvFile.getValue("CODE_EGRET"),"导出EGRET文件",Alert.YES|Alert.NO,null,forCodeEgret);
			else
				selectPath("CODE_EGRET","选择EGRET文件导出目录");
		}
		
		/**创建json并且压缩*/		
		public function createFileForJsonZip():void
		{
			//判断是否有默认的导出目录
			if(ProjectManager.kvFile.getValue("JSON_ZIP_PATH")!=null)
				Alert.show("是否导出到默认目录:"+ProjectManager.kvFile.getValue("JSON_ZIP_PATH"),"导出JSON压缩包",Alert.YES|Alert.NO,null,forJsonZip);
			else
				selectPath("JSON_ZIP_PATH","选择JSON压缩集导出目录");
		}
		
		/**将所有表格存储为JSON格式,一个表格存储一个对应的JSON文件*/		
		public function createFileForJSON():void
		{
			//判断是否有默认的导出目录
			if(ProjectManager.kvFile.getValue("JSON_PATH")!=null)
				Alert.show("是否导出到默认目录:"+ProjectManager.kvFile.getValue("JSON_PATH"),"导出JSON集",Alert.YES|Alert.NO,null,forJson);
			else
				selectPath("JSON_PATH","选择JSON集导出目录");
		}
		
		/**
		 * 设置某个导出类型的路径
		 * @param key
		 * @param title
		 */		
		public function selectPath(key:String,title:String):void
		{
			_pathTarget = key;
			var _file:File = new File();
			_file.browseForDirectory(title);
			_file.addEventListener(Event.SELECT,choosePath);
		}
		
		/**
		 * 目录选择完成
		 * @param evt
		 */		
		public function choosePath(evt:Event):void
		{
			var file:File = evt.target as File;
			file.removeEventListener(Event.SELECT,ProjectManager.choosePath);
			_selectPath = file.nativePath;
			Alert.show("是否将"+_selectPath+"设置为此功能默认导出路径","导出设置",Alert.YES|Alert.NO,null,forPath);
		}
		
		/**
		 * 设置为默认路径 
		 * @param evt
		 */		
		private function forPath(evt:CloseEvent):void
		{
			if(evt.detail==Alert.YES)//设置为默认目录
				ProjectManager.kvFile.setValue(_pathTarget,_selectPath);
			switch(_pathTarget)
			{
				case "JSON_PATH":
					exportJson(_selectPath);
					break;
				case "JSON_ZIP_PATH":
					exportJsonZip(_selectPath);
					break;
				case "CODE_AS":
					exportCodeAs(_selectPath);
					break;
				case "CODE_EGRET":
					exportCodeEgret(_selectPath);
					break;
			}
		}
		
		private function comHandler(evt:Event):void
		{
			var timer:Timer = new Timer(3000,1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE,timerHandler);
			timer.start();
		}
		
		/**
		 * 读取基础数据
		 * @param evt
		 */		
		private function timerHandler(evt:TimerEvent):void
		{
			var fileB:File = new File();
			fileB.browse();
			fileB.addEventListener(Event.SELECT,selected);
		}
		
		private function selected(e:Event):void
		{
			var file:File = e.target as File;
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,completedHandler);
			loader.load(new URLRequest(file.url));
		}
		
		/**
		 * 加载完成后对excel数据的调用
		 */
		private function completedHandler(evt:Event):void
		{
			var bts:ByteArray = evt.target.data as ByteArray;
			bts.inflate();
			var str:String = bts.readUTFBytes(bts.bytesAvailable);
			var obj:Object = JSON.parse(str);
			FlexGlobals.topLevelApplication.addLog("加载完成");
		}

		
		/**
		 * 导出基础数据
		 * 这里解析的是以数组存储的，数组中每一条为一个配置类。
		 * 每个类的封装形式为二维数组，以行为单位
		 * @param sheets 
		 */		
		public function exportSheets(sheets:Array):void
		{
			 while(sheets.length>0)
			 {
				 var exportData:ExportData = new ExportData((sheets.shift() as Sheet).values.toArray());
				 if(exportData.className)//如果为有效数据
				 {
					 //判断是否属于合并数据
					 if(_dic.hasOwnProperty(exportData.className)&&_dic[exportData.className]!=null)
						 (_dic[exportData.className] as ExportData).contact(exportData);
					 else
						 _dic[exportData.className] = exportData;
				 }
			 }
		}
		
		/**
		 * 计数器减一
		 */		
		private function completeHandler():void
		{
			count++;
		}
		
		//----------------------------------导出AS文件--------------------------------
		
		private function forCodeEgret(evt:CloseEvent):void
		{
			if(evt.detail==Alert.YES)
				exportCodeEgret(ProjectManager.kvFile.getValue("CODE_EGRET"));
			else
				selectPath("CODE_EGRET","选择EGRET文件导出目录");
		}
		
		private function forCodeAs(evt:CloseEvent):void
		{
			if(evt.detail==Alert.YES)
				exportCodeAs(ProjectManager.kvFile.getValue("CODE_AS"));
			else
				selectPath("CODE_AS","选择AS文件导出目录");
		}
		
		private function exportCodeAs(url:String):void
		{
			//首先需要找到符合条件的包路径
			if(url.indexOf("src\\")<0)
			{
				Alert.show("AS文件必须制定到对应包目录（src）");
				return;
			}
			var str:String = url.substr(url.indexOf("src\\"));
			var args:Array = str.split("\\");
			str = "";
			for(var i:int=1;i<args.length;i++)
			{
				str+=args[i];
				if(i+1<args.length)
					str+=".";
			}
			for(var key:* in _dic)
			{
				var expData:ExportData = _dic[key];
				var file:FileUtil = new FileUtil(url+"/"+expData.className+"LO.as");
				file.saveTxt(expData.getAsClassCode(str));
			}
			FlexGlobals.topLevelApplication.addLog("完成AS文件的输出!");
		}
		
		private function exportCodeEgret(url:String):void
		{
			for(var key:* in _dic)
			{
				var expData:ExportData = _dic[key];
				var file:FileUtil = new FileUtil(url+"/"+expData.className+"LO.ts");
				file.saveTxt(expData.getEgretClassCode());
			}
			FlexGlobals.topLevelApplication.addLog("完成AS文件的输出!");
		}
		
		//----------------------------------导出JSON并压缩---------------------------
			
		private function forJsonZip(evt:CloseEvent):void
		{
			if(evt.detail==Alert.YES)
				exportJsonZip(ProjectManager.kvFile.getValue("JSON_ZIP_PATH"));
			else
				selectPath("JSON_ZIP_PATH","选择JSON压缩包导出目录");
		}
		
		private function exportJsonZip(url:String):void
		{
			count = 0;
			totalCount = 0;
			FlexGlobals.topLevelApplication.addLog("保存JSON压缩包到目录:"+url);
			var file:FileUtil = new FileUtil(url+"/base.db");
			var bytes:ByteArray = new ByteArray();
			for(var key:* in _dic)
			{
				var bt2:ByteArray = new ByteArray();
				var expData:ExportData = _dic[key];
				bt2.writeUTFBytes(expData.getTotalJson());
				bt2.position = 0;
				bytes.writeUnsignedInt(bt2.bytesAvailable);
				bytes.writeBytes(bt2);
			}
			bytes.compress();
			file.saveBytes(bytes);
			FlexGlobals.topLevelApplication.addLog("完成!");
		}
		
		//----------------------------------导出JSON集--------------------------------
		
		private function forJson(evt:CloseEvent):void
		{
			if(evt.detail==Alert.YES)
				exportJson(ProjectManager.kvFile.getValue("JSON_PATH"));
			else
				selectPath("JSON_PATH","选择JSON集导出目录");
		}
		
		private function exportJson(url:String):void
		{
			count = 0;
			totalCount = 0;
			FlexGlobals.topLevelApplication.addLog("保存JSON数据集到目录:"+url);
			for(var key:* in _dic)
			{
				totalCount++;
			}
			for(key in _dic)
			{
				var expData:ExportData = _dic[key];
				var file:FileUtil = new FileUtil(url+"/"+expData.className+".json");
				file.saveAsJson(expData.datas,completeHandler);
			}
		}
	}
}