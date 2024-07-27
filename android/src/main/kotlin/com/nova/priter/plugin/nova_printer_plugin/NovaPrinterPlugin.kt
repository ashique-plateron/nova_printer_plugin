package com.nova.priter.plugin.nova_printer_plugin

import EpsonEposPlugin
import android.content.Context
import android.os.Handler
import android.os.Looper
import com.epson.epos2.Log
import com.epson.epos2.printer.Printer
import com.epson.epos2.printer.PrinterStatusInfo
import com.epson.epos2.printer.ReceiveListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** NovaPrinterPlugin */
class NovaPrinterPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var logTag: String = "Nova_Printer_Plugin"
    private lateinit var epsonEposPlugin: EpsonEposPlugin
    private lateinit var citizenFunctions: CitizenFunctions

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        epsonEposPlugin = EpsonEposPlugin(context)
        citizenFunctions = CitizenFunctions(context)
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "nova_printer_plugin")
        channel.setMethodCallHandler(this)
        Log.setLogSettings(
            context,
            Log.PERIOD_TEMPORARY,
            Log.OUTPUT_STORAGE,
            null,
            0,
            1,
            Log.LOGLEVEL_LOW
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val r = MethodResultWrapper(result)
        Thread(MethodRunner(call, r)).start()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    inner class MethodRunner(methodCall: MethodCall, r: Result) : Runnable, ReceiveListener {
        private val call: MethodCall = methodCall
        private val result: Result = r


        override fun onPtrReceive(p0: Printer?, p1: Int, p2: PrinterStatusInfo?, p3: String?) {
            android.util.Log.d(logTag, "${p0?.status} p2 $p2 p3 $p3")
            epsonEposPlugin.disconnectPrinter()

        }

        override fun run() {
            android.util.Log.d(logTag, "Method Called: ${call.method}")
            when (call.method) {
               "onDiscovery" -> {
                   epsonEposPlugin.onDiscovery(call, result)
               }

                "onPrint" -> {
                    epsonEposPlugin.onPrint(call, result)
                }

                "onGetPrinterInfo" -> {
                    epsonEposPlugin.onGetPrinterInfo(call, result)
                }

                "isPrinterConnected" -> {
                    epsonEposPlugin.isPrinterConnected(call, result)
                }

                "getPrinterSetting" -> {
                    epsonEposPlugin.getPrinterSetting(call, result)
                }

                "setPrinterSetting" -> {
                    epsonEposPlugin.setPrinterSetting(call, result)
                }

                "onCitizenPrint" -> {
                    citizenFunctions.onPrintCitizen(call, result)
                }

                else -> {
                    android.util.Log.d(logTag, "Method: ${call.method} is not supported yet")
                    result.notImplemented()
                }
            }
        }
    }

    class MethodResultWrapper(private val methodResult: Result) : Result {
        private val handler: Handler = Handler(Looper.getMainLooper())

        override fun success(result: Any?) {
            handler.post { methodResult.success(result) }
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            handler.post { methodResult.error(errorCode, errorMessage, errorDetails) }
        }

        override fun notImplemented() {
            handler.post { methodResult.notImplemented() }
        }
    }
}
