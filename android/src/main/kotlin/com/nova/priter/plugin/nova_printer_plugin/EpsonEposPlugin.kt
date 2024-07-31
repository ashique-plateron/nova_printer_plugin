import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Handler
import android.os.Looper
import android.util.Base64
import android.util.Log
import com.citizen.sdk.ESCPOSConst
import com.epson.epos2.Epos2Exception
import com.epson.epos2.discovery.Discovery
import com.epson.epos2.discovery.DiscoveryListener
import com.epson.epos2.discovery.FilterOption
import com.epson.epos2.printer.Printer
import com.epson.epos2.printer.PrinterSettingListener
import com.epson.epos2.printer.PrinterStatusInfo
import com.epson.epos2.printer.ReceiveListener
import com.google.gson.Gson
import com.nova.priter.plugin.nova_printer_plugin.PrinterResult
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result


interface JSONConvertable {
    fun toJSON(): String = Gson().toJson(this)
}

inline fun <reified T : JSONConvertable> String.toObject(): T = Gson().fromJson(this, T::class.java)


class EpsonEposPrinterInfo(
    var ipAddress: String? = null,
    var bdAddress: String? = null,
    var macAddress: String? = null,
    var model: String? = null,
    var type: String? = null,
    var printType: String? = null,
    var target: String? = null
) : JSONConvertable


/** EpsonEposPlugin */
@Suppress("CAST_NEVER_SUCCEEDS")
class EpsonEposPlugin(private val context: Context) {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    private var mPrinter: Printer? = null
    private var mTarget: String? = null
    private var printers: MutableList<EpsonEposPrinterInfo> = ArrayList()
    private var logTag: String = "Nova_Printer_Plugin"

    /**
     * Stop discovery printer
     */
    private fun stopDiscovery() {
        try {
            Discovery.stop()
        } catch (e: Epos2Exception) {
            if (e.errorStatus != Epos2Exception.ERR_PROCESSING) {
                //todo handle error
                Log.d(logTag, "stop Discovery error: ${e.errorStatus}")
            }
        }
    }

    /**
     * Discovery printers
     */
    fun onDiscovery(call: MethodCall, result: Result) {
        val printType: String? = call.argument<String>("type")
        Log.d(logTag, "onDiscovery type: $printType")
        when (printType) {
            "TCP" -> {
                onDiscoveryTCP(call, result)
            }

            "USB" -> {
                onDiscoveryUSB(call, result)
            }

            else -> result.notImplemented()
        }
    }

    /**
     * Discovery Printers via TCP/IP
     */
    fun onDiscoveryTCP(call: MethodCall, result: Result) {
        printers.clear()
        val filter = FilterOption()
        filter.portType = Discovery.PORTTYPE_TCP
        val resp = PrinterResult("onDiscoveryTCP", false)
        try {
            Discovery.start(context, filter, mDiscoveryListener)
            Handler(Looper.getMainLooper()).postDelayed({
                resp.success = true
                resp.message = "Successfully!"
                resp.content = printers
                result.success(resp.toJSON())
                stopDiscovery()
            }, 7000)
        } catch (e: Exception) {
            Log.e("OnDiscoveryTCP", "Start not working ${call.method}");
            e.printStackTrace()
            resp.success = false
            resp.message = "Error while search printer"
            result.success(resp.toJSON())
        }
    }


    /**
     * Discovery Printers via TCP/IP
     */
    fun onDiscoveryUSB(call: MethodCall, result: Result) {
        printers.clear()
        val filter = FilterOption()
        filter.portType = Discovery.PORTTYPE_USB
        val resp = PrinterResult("onDiscoveryUSB", false)
        try {
            Discovery.start(context, filter, mDiscoveryListener)
            Handler(Looper.getMainLooper()).postDelayed({
                resp.success = true
                resp.message = "Successfully!"
                resp.content = printers
                result.success(resp.toJSON())
                stopDiscovery()
            }, 1000)
        } catch (e: Exception) {
            Log.e("OnDiscoveryTCP", "Start not working ${call.method}");
            e.printStackTrace()
            resp.success = false
            resp.message = "Error while search printer"
            result.success(resp.toJSON())
        }
    }

    fun onGetPrinterInfo(call: MethodCall, result: Result) {
        Log.d(logTag, "onGetPrinterInfo $call $result")
    }

    fun isPrinterConnected(call: MethodCall, result: Result) {
        Log.d(logTag, "isPrinterConnected $call $result")
    }

    fun getPrinterSetting(call: MethodCall, result: Result) {
        Log.d(logTag, "getPrinterSetting $call $result")

        val type: String = call.argument<String>("type") as String
        val series: String = call.argument<String>("series") as String
        val target: String = call.argument<String>("target") as String

        val resp = PrinterResult("onPrint${type}", false)
        try {
            if (!connectPrinter(target, series)) {
                resp.success = false
                resp.message = printerStatusError()//"Can not connect to the printer."
                result.success(resp.toJSON())
                mPrinter!!.clearCommandBuffer()
            } else {
                if (mPrinter != null) {
                    mPrinter!!.clearCommandBuffer()
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            resp.success = false
            resp.message = "Print error"
            result.success(resp.toJSON())
        }
    }

    fun setPrinterSetting(call: MethodCall, result: Result) {
        Log.d(logTag, "setPrinterSetting $call $result")

        val type: String = call.argument<String>("type") as String
        val series: String = call.argument<String>("series") as String
        val target: String = call.argument<String>("target") as String

        val paperWidth: Int? = call.argument<String>("paper_width") as? Int
        val printDensity: Int? = call.argument<String>("print_density") as? Int
        val printSpeed: Int? = call.argument<String>("print_speed") as? Int

        val resp = PrinterResult("onPrint${type}", false)
        try {
            if (!connectPrinter(target, series)) {
                resp.success = false
                resp.message = printerStatusError()//"Can not connect to the printer."
                result.success(resp.toJSON())
                mPrinter!!.clearCommandBuffer()
            } else {
                val settingList = HashMap<Int, Int>()
                settingList[Printer.SETTING_PRINTSPEED] = printSpeed ?: Printer.PARAM_DEFAULT
                settingList[Printer.SETTING_PRINTDENSITY] = printDensity ?: Printer.PARAM_DEFAULT
                var pw = 80
                if (paperWidth != null) {
                    pw = if (paperWidth != 80 || paperWidth != 58 || paperWidth != 60) {
                        80
                    } else {
                        paperWidth
                    }
                }
                settingList[Printer.SETTING_PAPERWIDTH] = pw
                try {
                    mPrinter!!.setPrinterSetting(
                        Printer.PARAM_DEFAULT,
                        settingList,
                        mPrinterSettingListener
                    )
                } catch (ex: Exception) {
                    Log.e(logTag, "sendData Error", ex)
                    ex.printStackTrace()
                    resp.success = false
                    resp.message = "Print error"
                    result.success(resp.toJSON())
                } finally {
                    disconnectPrinter()
                }

            }
        } catch (e: Exception) {
            e.printStackTrace()
            resp.success = false
            resp.message = "Print error"
            result.success(resp.toJSON())
        }
    }

    /**
     * Print
     */
    fun onPrint(call: MethodCall, result: Result) {
        val type: String = call.argument<String>("type") as String
        val series: String = call.argument<String>("series") as String
        val target: String = call.argument<String>("target") as String

        val commands: ArrayList<Map<String, Any>> =
            call.argument<ArrayList<Map<String, Any>>>("commands") as ArrayList<Map<String, Any>>
        val resp = PrinterResult("onPrint${type}", false)
        try {
            if (!connectPrinter(target, series)) {
                if (mPrinter != null) {
                    mPrinter!!.clearCommandBuffer()
                }
                resp.success = false
                resp.message = "Can not connect to the printer."
                result.success(resp.toJSON())
                Log.e(logTag, "Cannot ConnectPrinter $resp")
            } else {
                mPrinter!!.clearCommandBuffer()
                commands.forEach {
                    onGenerateCommand(it)
                }
                try {
                    mPrinter!!.sendData(Printer.PARAM_DEFAULT)
                    mPrinter!!.setReceiveEventListener(object : ReceiveListener {
                        override fun onPtrReceive(
                            p0: Printer?,
                            p1: Int,
                            p2: PrinterStatusInfo?,
                            p3: String?
                        ) {
                            disconnectPrinter()
                            resp.success = true
                            resp.message =
                                "Printed $target $series | ERROR CODE ${p2?.errorStatus.toString()}"
                            Log.d(logTag, resp.toJSON())
                            result.success(resp.toJSON());
                        }
                    })
                    Log.d(logTag, "Printed $target $series")
                } catch (ex: Epos2Exception) {
                    mPrinter?.clearCommandBuffer()
                    ex.printStackTrace()
                    Log.e(logTag, "sendData Error" + ex.errorStatus, ex)
                    resp.success = false
                    resp.message = "Can not connect to the printer."
                    result.success(resp.toJSON())

                } catch (e: Exception) {
                    mPrinter?.clearCommandBuffer()
                    e.printStackTrace()
                    Log.e(logTag, "sendData Error" + e.message, e)
                    resp.success = false
                    resp.message = "Printed $target $series."
                    result.success(resp.toJSON())
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            resp.success = false
            resp.message = "Print error"
            result.success(resp.toJSON())
        }
    }

    /// FUNCTIONS

    private val mDiscoveryListener = DiscoveryListener { deviceInfo ->
        Log.d(logTag, "Found: ${deviceInfo?.deviceName}")
        if (deviceInfo?.deviceName != null && deviceInfo.deviceName != "") {
            val printer = EpsonEposPrinterInfo(
                deviceInfo.ipAddress,
                deviceInfo.bdAddress,
                deviceInfo.macAddress,
                deviceInfo.deviceName,
                deviceInfo.deviceType.toString(),
                deviceInfo.deviceType.toString(),
                deviceInfo.target
            )
            if (printer.target?.contains("TCPS") == true) {
                Log.e("Invalid Printer", printer.target.toString())
            } else {
                val printerIndex =
                    printers.indexOfFirst { e -> e.ipAddress == deviceInfo.ipAddress }
                if (printerIndex > -1) {
                    printers[printerIndex] = printer
                } else {
                    printers.add(printer)
                }
            }
        }

    }

    val mPrinterSettingListener = object : PrinterSettingListener {
        override fun onGetPrinterSetting(p0: Int, p1: Int, p2: Int) {
            Log.e("logTag", "onGetPrinterSetting type: $p0 $p1 $p2")
        }

        override fun onSetPrinterSetting(p0: Int) {
            Log.e("logTag", "onSetPrinterSetting Code: $p0")
        }
    }

    private fun connectPrinter(target: String, series: String): Boolean {
        val printCons = getPrinterConstant(series)
        if (mPrinter == null || mTarget != target) {
            if (mPrinter != null) {
                try {
                    mPrinter!!.clearCommandBuffer()
                    disconnectPrinter()
                } catch (e: Exception) {
                    mPrinter!!.clearCommandBuffer()
                    Log.e(logTag, "Disconnect Error ${e.message}", e)
                }
            }
            mPrinter = Printer(printCons, 0, context)
            mTarget = target
        }
        Log.d(logTag, "Connect Printer w $series constant: $printCons via $target")
        try {
            val status: PrinterStatusInfo? = mPrinter!!.status;
            if (status?.online != Printer.TRUE) {
                mPrinter!!.connect(target, Printer.PARAM_DEFAULT)
            }
            mPrinter!!.clearCommandBuffer()
        } catch (e: Epos2Exception) {
            Log.d(logTag, "Connect failed")
            e.printStackTrace()
            disconnectPrinter()
            Log.e(logTag, "Connect Error ${e.errorStatus}", e)
            return false
        }
        return true
    }

    fun disconnectPrinter() {
        if (mPrinter == null) {
            Log.d(logTag, "disconnectPrinter mPrinter null")
            return
        }
        try {
            mPrinter!!.disconnect()
        } catch (e: Epos2Exception) {
            Log.d(logTag, "Disconnect failed")
//            e.printStackTrace()
            Log.e(logTag, "Disconnect Error ${e.errorStatus}", e)
        }
        mPrinter!!.clearCommandBuffer()
    }

    private fun onGenerateCommand(command: Map<String, Any>) {
        if (mPrinter == null) return
        Log.d(logTag, "onGenerateCommand [EPSON]: $command")

        val commandId: String = command["type"] as String
        if (commandId.isNotEmpty()) {
            val commandValue: Map<String, Any> = command["attributes"] as Map<String, Any>
            Log.d(logTag, "COMMAND: [$commandValue]")
            when (commandId) {

                "printText" -> {
                    val text = commandValue["text"]
                    val alignment = commandValue["alignment"]
                    val font = commandValue["fontType"]
                    val size: Map<String, Int> = commandValue["size"] as Map<String, Int>
                    val style: Map<String, Int> = commandValue["style"] as Map<String, Int>
                    val smoothenText =
                        if (commandValue["textSmooth"] as? Boolean == true) Printer.TRUE else Printer.FALSE

                    var textAlign = Printer.PARAM_DEFAULT;
                    when (alignment) {
                        "LEFT" -> textAlign = Printer.ALIGN_LEFT
                        "CENTRE" -> textAlign = Printer.ALIGN_CENTER
                        "RIGHT" -> textAlign = Printer.ALIGN_RIGHT
                    }

                    var fontType = Printer.PARAM_DEFAULT;
                    when (font.toString()) {
                        "FONT_A" -> {
                            fontType = Printer.FONT_A
                        }

                        "FONT_B" -> {
                            fontType = Printer.FONT_B
                        }

                        "FONT_C" -> {
                            fontType = Printer.FONT_C
                        }

                        "FONT_D" -> {
                            fontType = Printer.FONT_D
                        }

                        "FONT_E" -> {
                            fontType = Printer.FONT_E

                        }
                    }

                    val width = (size["width"] as? Int) ?: Printer.PARAM_DEFAULT
                    val height = (size["height"] as? Int) ?: Printer.PARAM_DEFAULT

                    val reverse =
                        if (style["reverse"] as? Boolean == true) Printer.TRUE else Printer.FALSE
                    val ul =
                        if (style["underline"] as? Boolean == true) Printer.TRUE else Printer.FALSE
                    val em = if (style["em"] as? Boolean == true) Printer.TRUE else Printer.FALSE
                    val color = style["color"] as String?

                    val colorValue = when (color) {
                        "COLOR_NONE" -> Printer.COLOR_NONE
                        "COLOR_1" -> Printer.COLOR_1
                        "COLOR_2" -> Printer.COLOR_2
                        "COLOR_3" -> Printer.COLOR_3
                        "COLOR_4" -> Printer.COLOR_4
                        else -> Printer.PARAM_DEFAULT
                    }

                    mPrinter!!.addTextSmooth(smoothenText)
                    mPrinter!!.addTextStyle(reverse, ul, em, colorValue)
                    mPrinter!!.addTextSize(width, height)
                    mPrinter!!.addTextFont(fontType)
                    mPrinter!!.addTextAlign(textAlign)
                    mPrinter!!.addText(text.toString())
                }

                "addCut" -> {
                    var cutType = commandValue["cutType"] as String
                    when (cutType) {
                        "CUT_FEED" -> {
                            mPrinter!!.addCut(Printer.CUT_FEED)
                        }

                        "CUT_NO_FEED" -> {
                            mPrinter!!.addCut(Printer.CUT_NO_FEED)
                        }

                        "CUT_RESERVE" -> {
                            mPrinter!!.addCut(Printer.CUT_RESERVE)
                        }

                        else -> {
                            mPrinter!!.addCut(Printer.PARAM_DEFAULT)
                        }
                    }
                }

                "addFeedLine" -> {
                    var lines = commandValue["lines"] as Int
                    mPrinter!!.addFeedLine(lines)
                }

                "printRawData" -> {
                    try {
                        Log.d(logTag, "printRawData")
                        mPrinter!!.addCommand(commandValue as ByteArray)
                    } catch (e: Exception) {
                        Log.e(logTag, "onGenerateCommand Error" + e.localizedMessage)
                    }
                }

                "addImage" -> {
                    try {
                        val width: Int? = commandValue["width"] as? Int
                        val height: Int? = commandValue["height"] as? Int
                        val posX: Int? = commandValue["posX"] as? Int
                        val posY: Int? = commandValue["posY"] as? Int

                        var mode = when (commandValue["mode"].toString()) {
                            "MODE_MONO" -> Printer.MODE_MONO
                            "MODE_GRAY16" -> Printer.MODE_GRAY16
                            else -> Printer.PARAM_DEFAULT
                        }
                        var ht = commandValue["halftone"];
                        val halftone = when (ht.toString()) {
                            "HALFTONE_DITHER" -> Printer.HALFTONE_DITHER
                            "HALFTONE_ERROR_DIFFUSION" -> Printer.HALFTONE_ERROR_DIFFUSION
                            "HALFTONE_THRESHOLD" -> Printer.HALFTONE_THRESHOLD
                            else -> Printer.PARAM_DEFAULT
                        }


                        val brightness: Double? = commandValue["brightness"] as? Double
                        val compress: Int? = commandValue["compress"] as? Int
                        var byteArray: ByteArray = (commandValue["bitmap"] as ByteArray)
                        val bitmap: Bitmap? =
                            BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
                        Log.d(logTag, "appendBitmap: $width x $height $posX $posY bitmap $bitmap")
                        Printer.SETTING_PAPERWIDTH_80_0
                        mPrinter!!.addImage(
                            bitmap,
                            posX ?: Printer.PARAM_DEFAULT,
                            posY ?: Printer.PARAM_DEFAULT,
                            width ?: Printer.PARAM_DEFAULT,
                            height ?: Printer.PARAM_DEFAULT,
                            Printer.PARAM_DEFAULT,
                            mode,
                            halftone ?: Printer.PARAM_DEFAULT,
                            brightness ?: 1.0,
                            compress ?: Printer.COMPRESS_NONE
                        )
                    } catch (e: Exception) {
                        Log.e(logTag, "onGenerateCommand Error" + e.localizedMessage)
                    }
                }

                "printQRCode" -> {
                    var data: String? = commandValue["data"] as? String
                        ?: throw RuntimeException("COMMAND ID :$commandId | error: QR DATA IS NULL $commandValue ")

                    var size = commandValue["size"] as? Int ?: 3

                    var ecLevel = when (commandValue["errorCorrectionLevel"]) {
                        "LOW" -> Printer.LEVEL_L
                        "MEDIUM" -> Printer.LEVEL_M
                        "QUARTER" -> Printer.LEVEL_Q
                        "HIGH" -> Printer.LEVEL_H
                        else -> Printer.PARAM_DEFAULT
                    }
                    mPrinter!!.addTextAlign(Printer.ALIGN_CENTER)
                    mPrinter!!.addSymbol(
                        data,
                        Printer.SYMBOL_QRCODE_MODEL_2,
                        ecLevel,
                        size,
                        size,
                        3,
                    );
                    mPrinter!!.addTextAlign(Printer.ALIGN_LEFT)
                }
            }
        }
    }

    private fun getPrinterConstant(series: String): Int {
        return when (series) {
            "TM_M10" -> Printer.TM_M10
            "TM_M30" -> Printer.TM_M30
            "TM_M30II" -> Printer.TM_M30II
            "TM_M50" -> Printer.TM_M50
            "TM_P20" -> Printer.TM_P20
            "TM_P60" -> Printer.TM_P60
            "TM_P60II" -> Printer.TM_P60II
            "TM_P80" -> Printer.TM_P80
            "TM_T20" -> Printer.TM_T20
            "TM_T60" -> Printer.TM_T60
            "TM_T70" -> Printer.TM_T70
            "TM_T81" -> Printer.TM_T81
            "TM_T82" -> Printer.TM_T82
            "TM_T83" -> Printer.TM_T83
            "TM_T83III" -> Printer.TM_T83III
            "TM_T88" -> Printer.TM_T88
            "TM_T90" -> Printer.TM_T90
            "TM_T100" -> Printer.TM_T100
            "TM_U220" -> Printer.TM_U220
            "TM_U330" -> Printer.TM_U330
            "TM_L90" -> Printer.TM_L90
            "TM_H6000" -> Printer.TM_H6000
            else -> 0
        }
    }

    fun convertBase64toBitmap(base64Str: String): Bitmap? {
        val decodedBytes: ByteArray = Base64.decode(base64Str, Base64.DEFAULT)
        return BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size)
    }

    fun printerStatusError(): String {
        if (mPrinter == null) {
            return getErrorMessage("");
        }
        var errorMes = "";
        val status: PrinterStatusInfo? = mPrinter!!.status;

        if (status?.online == Printer.FALSE) {
            errorMes = getErrorMessage("err_offline")
        }

        if (status?.connection == Printer.FALSE) {
            errorMes = getErrorMessage("err_no_response")
        }

        if (status?.coverOpen == Printer.TRUE) {
            errorMes = getErrorMessage("err_cover_open")
        }

        if (status?.paper == Printer.PAPER_EMPTY) {
            errorMes = getErrorMessage("err_receipt_end")
        }

        if (status?.paperFeed == Printer.TRUE || status?.panelSwitch == Printer.SWITCH_ON) {
            errorMes = getErrorMessage("err_paper_feed")
        }

        if (status?.errorStatus == Printer.UNRECOVER_ERR) {
            errorMes = getErrorMessage("err_unrecover")
        }

        if (status?.errorStatus == Printer.MECHANICAL_ERR || status?.errorStatus == Printer.AUTOCUTTER_ERR) {
            errorMes = getErrorMessage("err_autocutter")
            errorMes += getErrorMessage("err_need_recover")
        }

        if (status?.errorStatus == Printer.AUTORECOVER_ERR) {
            if (status.autoRecoverError == Printer.HEAD_OVERHEAT) {
                errorMes = getErrorMessage("err_overheat")
                errorMes += getErrorMessage("err_head")
            }
            if (status.autoRecoverError == Printer.MOTOR_OVERHEAT) {
                errorMes = getErrorMessage("err_overheat")
                errorMes += getErrorMessage("err_motor")
            }
            if (status.autoRecoverError == Printer.BATTERY_OVERHEAT) {
                errorMes = getErrorMessage("err_overheat")
                errorMes += getErrorMessage("err_battery")
            }
            if (status.autoRecoverError == Printer.WRONG_PAPER) {
                errorMes += getErrorMessage("err_wrong_paper")
            }
        }
        if (status?.batteryLevel == Printer.BATTERY_LEVEL_0) {
            errorMes = getErrorMessage("err_battery_real_end")
        }

        if (errorMes == "") {
            return getErrorMessage("");
        }
        return errorMes
    }

    fun getErrorMessage(errorKey: String, withNewLine: Boolean = true): String {
        val errorMes = when (errorKey) {
            "warn_receipt_near_end" -> {
                "Roll paper is nearly end."
            }

            "warn_battery_near_end" -> {
                "Battery level of printer is low."
            }

            "err_no_response" -> {
                "Please check the connection of the printer and the mobile terminal.\nConnection get lost."
            }

            "err_cover_open" -> {
                "Please close roll paper cover."
            }

            "err_receipt_end" -> {
                "Please check roll paper."
            }

            "err_paper_feed" -> {
                "Please release a paper feed switch."
            }

            "err_autocutter" -> {
                "Please remove jammed paper and close roll paper cover.\nRemove any jammed paper or foreign substances in the printer, and then turn the printer off and turn the printer on again."
            }

            "err_need_recover" -> {
                "Then, If the printer doesn\'t recover from error, please cycle the power switch."
            }

            "err_unrecover" -> {
                "Please cycle the power switch of the printer.\nIf same errors occurred even power cycled, the printer may out of orde"
            }

            "err_overheat" -> {
                "Please wait until error LED of the printer turns off. "
            }

            "err_head" -> {
                "Print head of printer is hot."
            }

            "err_motor" -> {
                "Motor Driver IC of printer is hot."
            }

            "err_battery" -> {
                "Battery of printer is hot."
            }

            "err_wrong_paper" -> {
                "Please set correct roll paper."
            }

            "err_battery_real_end" -> {
                "Please connect AC adapter or change the battery.\nBattery of printer is almost empty."
            }

            "err_offline" -> {
                "Printer is offline."
            }

            else -> "Unknown error. Please check the power and communication status of the printer."
        }
        if (withNewLine) {
            return "$errorMes\n"
        }
        return errorMes
    }


}
