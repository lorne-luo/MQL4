//+------------------------------------------------------------------+
//|                                                 TradeContext.mq4 |
//|                                                        komposter |
//|                                             komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "komposter"
#property link      "komposterius@mail.ru"

/////////////////////////////////////////////////////////////////////////////////
/**/ int _IsTradeAllowed( int MaxWaiting_sec = 30 )
/////////////////////////////////////////////////////////////////////////////////
// 交易作业的状态指定函数。返回代码：
//  1 - 交易作业空闲，可以交易
//  0 - 交易作业刚刚空闲。在市场信息更新后可以交易。
// -1 - 交易作业忙，等待(从图表中删除智能交易, 关闭终端, 
// 	  改变时间周期/图表货币对, ... )
// -2 - 交易作业忙,最大等待时间(MaxWaiting_sec)。可能智能交易禁止交易
// 	   (在智能交易设之中选择"允许交易"选项）.
//
// MaxWaiting_sec -时间 (秒钟）, 在这段时间内交易作业函数会等待空闲 (如果作业忙） 
//  默认值 = 30.
/////////////////////////////////////////////////////////////////////////////////
{
	// 检测交易作业是否空闲
	if ( !IsTradeAllowed() )
	{
		int StartWaitingTime = GetTickCount();
		Print( "交易作业忙，等待空闲..." );
		// 无限循环
		while ( true )
		{
			// 如果智能交易被用户打断，停止运作
			if ( IsStopped() ) { Print( "智能交易被用户打断!" ); return(-1); }
			// 如果等待时间超出最大等待时间MaxWaiting_sec, 同样停止运作
			if ( GetTickCount() - StartWaitingTime > MaxWaiting_sec * 1000 ) { Print( "最大等待限定 (" + MaxWaiting_sec + " сек.)!" ); return(-2); }
			// 如果交易作业空闲
			if ( IsTradeAllowed() )
			{
				Print( "交易作业空闲!" );
				return(0);
			}
			// 如果无条件中断循环, "等待" 0,1 秒并重新开始检测
			Sleep(100);
		}
	}
	else
	{
		Print( "交易作业空闲!" );
		return(1);
	}
}
/*
智能交易模板 , 使用函数 _IsTradeAllowed:
int start()
{
	// 确定进入市场
	...
	// 计算止损，赢利和标准手数
	...
	// 检测交易作业是否空闲
	int TradeAllow = _IsTradeAllowed();
	if ( TradeAllow < 0 ) { return(-1); }
	if ( TradeAllow == 0 )
	{
		RefreshRates();
		// 重新计算止损和赢利水平
		...
	}
	// 开仓
	OrderSend(.....);
return(0);
}
*/

/////////////////////////////////////////////////////////////////////////////////
/**/ int TradeIsBusy ( int MaxWaiting_sec = 30 )
/////////////////////////////////////////////////////////////////////////////////
// 函数改变政体变量TradeIsBusy 0 到 1.
// 如果开始 TradeIsBusy = 1, 函数等待, 暂时 TradeIsBusy  = 0, 随后改变.
// 如果整体变量TradeIsBusy不存在，函数会创建
// 返回代码:
//  1 - 成功完成。 整体变量TradeIsBusy 值为 1
// -1 - 开始函数 TradeIsBusy = 1, 交易作业忙，等待(从图表中删除智能交易, 关闭终端, 
// 	  改变时间周期/图表货币对, ... )
// -2 -开始函数TradeIsBusy = 1,最大等待期限(MaxWaiting_sec)
/////////////////////////////////////////////////////////////////////////////////
{
	// 对于交易作业的测试 - 只是结束函数运行
	if ( IsTesting() ) { return(1); }
	int _GetLastError = 0, StartWaitingTime = GetTickCount();

	//+------------------------------------------------------------------+
	//| 检查变量是否存在。如果没有，创建它
	//+------------------------------------------------------------------+
	while( true )
	{
		//  如果智能交易被用户打断，停止运作
		if ( IsStopped() ) { Print( "智能交易被用户打断!" ); return(-1); }
		// 如果等待时间超出最大等待时间MaxWaiting_sec, 同样停止运作
		if ( GetTickCount() - StartWaitingTime > MaxWaiting_sec * 1000 ) { Print( "最大等待限定 (" + MaxWaiting_sec + " сек.)!" ); return(-2); }
		// 检查变量是否存在
		if ( GlobalVariableCheck( "TradeIsBusy" ) )
		// 如果存在推出循环模式并进行改变 TradeIsBusy值
		{ break; }
		else
		// 如果GlobalVariableCheck 返回 FALSE,意味着变量不存在或者生成错误
		{
			_GetLastError = GetLastError();
			// 如果错误生成，显示信息，等待 0,1秒并重新开始
			if ( _GetLastError != 0 )
			{
				Print( "TradeIsBusy() - GlobalVariableCheck ( \"TradeIsBusy\" ) - Error #", _GetLastError );
				Sleep(100);
				continue;
			}
		}

		// 如果没有错误，说明没有整体变量。尝试创建
		if ( GlobalVariableSet ( "TradeIsBusy", 1.0 ) > 0 )
		//如果GlobalVariableSet > 0,说明整体变量成功创建。退出函数。
		{ return(1); }
		else
		// 如果GlobalVariableSet 返回值<= 0, 说明创建过程中生成错误
		{
			_GetLastError = GetLastError();
			//现实信息, 等待 0,1 秒并重新开始
			if ( _GetLastError != 0 )
			{
				Print( "TradeIsBusy() - GlobalVariableSet ( \"TradeIsBusy\", 0.0 ) - Error #", _GetLastError );
				Sleep(100);
				continue;
			}
		}
	}

	//+------------------------------------------------------------------+
	//| 如果函数执行到达此点，说明整体变量存在
	//| 等待TradeIsBusy变为0 并将 TradeIsBusy值从 0 改变为 1
	//+------------------------------------------------------------------+
	while( true )
	{
		// 如果智能交易被用户打断，停止运作
		if ( IsStopped() ) { Print( "智能交易被用户终止!" ); return(-1); }
		// 如果等待时间超出最大等待时间MaxWaiting_sec, 同样停止运作
		if ( GetTickCount() - StartWaitingTime > MaxWaiting_sec * 1000 ) { Print( "最大等待限定(" + MaxWaiting_sec + " сек.)!" ); return(-2); }
		// 尝试改变TradeIsBusy 值从0到 1
		if ( GlobalVariableSetOnCondition( "TradeIsBusy", 1.0, 0.0 ) )
		// 如果成功, 现实信息,返回 1 - "成功完成"
		{ return(1); }
		else
		//如果没有可能存在两个原因: TradeIsBusy = 1 (需要等待)或生成错误 (我们要检测)
		{
			_GetLastError = GetLastError();
			// 如果生成错误，显示信息并重试
			if ( _GetLastError != 0 )
			{
				Print( "TradeIsBusy() - GlobalVariableSetOnCondition ( \"TradeIsBusy\", 1.0, 0.0 ) - Error #", _GetLastError );
				continue;
			}
		}

		// 如果错误不存在，说明 TradeIsBusy = 1 (其他智能交易在交易中) -形式信息并等待...
		Comment ( "等待，其他智能交易在交易中.." );
		Sleep(1000);
	}
}

/////////////////////////////////////////////////////////////////////////////////
/**/ void TradeIsNotBusy ()
/////////////////////////////////////////////////////////////////////////////////
// 函数安装的整体变量TradeIsBusy = 0.
// 如果整体变量TradeIsBusy 不存在，函数创建。
// 在没有完承任务以前,函数不会停止运行。
/////////////////////////////////////////////////////////////////////////////////
{
	// 对于交易作业的测试 - 只是结束函数运行
	if ( IsTesting() ) { return(0); }
	int _GetLastError;

	while( true )
	{
		// 尝试安装整体变量值= 0 (或创建整体变量)
		if ( GlobalVariableSet( "TradeIsBusy", 0.0 ) > 0 )
		//如果GlobalVariableSet 返回值 > 0, 说明成功完成。显示信息
		{ return(1); }
		else
		// 如果GlobalVariableSet 返回值<= 0, 说明生成错误。显示信息。 等待并重试
		{
			_GetLastError = GetLastError();
			if ( _GetLastError != 0 )
			{ Print( "TradeIsNotBusy() - GlobalVariableSet ( \"TradeIsBusy\", 0.0 ) - Error #", _GetLastError ); }
		}
		Sleep(100);
	}
}

/*
智能交易模板使用函数 TradeIsBusy()和 TradeIsNotBusy():

#include <TradeContext.mqh>

int start()
{
	//  确定进入市场
	...
	//计算止损，赢利和标准手数
	...
	// 等待市场空闲并占据(如果生成错误，退出)
	if ( TradeIsBusy() < 0 ) { return(-1); }
	//显示市场信息
	RefreshRates();
	//  重新计算止损和赢利水平
	...
	// 开仓
	OrderSend(.....);
	// 交易作业空闲
	TradeIsNotBusy();
return(0);
}
*/