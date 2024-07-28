package com.nova.priter.plugin.nova_printer_plugin

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.hardware.usb.UsbDevice
import android.util.Log
import com.citizen.sdk.ESCPOSConst
import com.citizen.sdk.ESCPOSPrinter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result


class CitizenEposPlugin(val mContext: Context) {

    private var logTag: String = "Nova_Printer_Plugin"


    fun onPrintCitizen(call: MethodCall, result: Result): Boolean {
        var posPtr = ESCPOSPrinter();
        posPtr.setContext(mContext)
        val usbDevice: UsbDevice? = null
        var result: Int

        //Arguments
        val commands: ArrayList<Map<String, Any>> =
            call.argument<ArrayList<Map<String, Any>>>("commands") as ArrayList<Map<String, Any>>
        val connectionType = call.argument<String?>("type");
        var address = call.argument<String?>("target") ?: ""

        if (commands == null || posPtr == null) return false

        var type = when (connectionType) {
            "USB" -> ESCPOSConst.CMP_PORT_USB
            "WIFI" -> ESCPOSConst.CMP_PORT_WiFi
            "BLUETOOTH" -> ESCPOSConst.CMP_PORT_Bluetooth
            else -> ESCPOSConst.CMP_PORT_USB
        }

        // Connect
        var connected = connect(posPtr, type, usbDevice, address);
        if (!connected) return false

        // Printer Check
        result = posPtr.printerCheck()
        if (ESCPOSConst.CMP_SUCCESS != result) return false

        // Get Status
        result = posPtr.status()
        if (ESCPOSConst.CMP_STS_NORMAL != result) return false

        // Character set
        result = posPtr.setEncoding("ISO-8859-1") // Latin-1

        //result = posPtr.setEncoding( "Shift_JIS" );		// Japanese 日本語を印字する場合は、この行を有効にしてください.
        if (ESCPOSConst.CMP_SUCCESS != result) return false

        try {
            // Start Transaction ( Batch )
            result = posPtr.transactionPrint(ESCPOSConst.CMP_TP_TRANSACTION)
            if (ESCPOSConst.CMP_SUCCESS != result) throw RuntimeException()

            commands.forEach {
                onGenerateCommand(posPtr, it)
            }

            // End Transaction ( Batch )
            result = posPtr.transactionPrint(ESCPOSConst.CMP_TP_NORMAL)
            if (ESCPOSConst.CMP_SUCCESS != result) {
                throw RuntimeException()
            } else {
                //DISCONNECT AFTER SUCCESSFUL PRINT
                disconnect(posPtr)
                Log.e(
                    "CITIZEN PRINTER",
                    "DISCONNECTED {result:${result}}",
                );
            }
        } catch (e: RuntimeException) {
            // Clear all buffered output data by transactionPrint.
            posPtr.clearOutput()
            return false
        }

        return true
    }

    private fun connect(
        posPtr: ESCPOSPrinter?,
        connectType: Int,
        usbDevice: UsbDevice?,
        addr: String,
    ): Boolean {
        if (posPtr == null) return false
        var bRet = false
        var result = 0;

        result = when (connectType) {
            // Connect to USB
            ESCPOSConst.CMP_PORT_USB -> {
                posPtr.connect(connectType, usbDevice)
            }
            // Connect to WIFI
            ESCPOSConst.CMP_PORT_WiFi -> {
                posPtr.connect(connectType, addr)
            }
            // Connect to BLUETOOTH
            ESCPOSConst.CMP_PORT_Bluetooth -> {
                posPtr.connect(connectType, addr)
            }

            else -> {
                // Unknown connection type
                return false
            }
        }
        // connect() Success
        bRet = ESCPOSConst.CMP_SUCCESS == result;
        return bRet
    }

    private fun disconnect(posPtr: ESCPOSPrinter?): Boolean {
        var bRet = false
        if (posPtr == null) return bRet
        // Disconnect
        val result = posPtr.disconnect()
        bRet = ESCPOSConst.CMP_SUCCESS == result
        return bRet
    }

    private fun onGenerateCommand(posPtr: ESCPOSPrinter, command: Map<String, Any>) {
        Log.d(logTag, "onGenerateCommand [CITIZEN]: $command")
        var result: Int = ESCPOSConst.CMP_SUCCESS;
        try {

            val commandId: String = command["type"] as String
            if (commandId.isNotEmpty()) {
                val commandValue: Map<String, Any> = command["attributes"] as Map<String, Any>
                Log.d(logTag, "COMMAND: [$commandValue]")

                var align = when (commandValue["alignment"]) {
                    "LEFT" -> ESCPOSConst.CMP_ALIGNMENT_LEFT
                    "CENTER" -> ESCPOSConst.CMP_ALIGNMENT_CENTER
                    "RIGHT" -> ESCPOSConst.CMP_ALIGNMENT_RIGHT
                    else -> ESCPOSConst.CMP_ALIGNMENT_LEFT
                }

                when (commandId) {

                    "printText" -> {
                        val text = commandValue["text"]
                        val font = commandValue["fontType"]
                        val size: Map<String, Int> = commandValue["size"] as Map<String, Int>
                        val style: Map<String, Int> = commandValue["style"] as Map<String, Int>
                        val reverse = style["reverse"] as? Boolean == true
                        val underline = style["underline"] as? Boolean == true
                        val bold = style["em"] as? Boolean == true
                        var width = (size["width"] as? Int) ?: ESCPOSConst.CMP_TXT_1WIDTH
                        var height = (size["height"] as? Int) ?: ESCPOSConst.CMP_TXT_1HEIGHT

                        val color = style["color"] as String?
                        val smoothenText = commandValue["textSmooth"] as? Boolean == true


                        var fontType = if (reverse) {
                            ESCPOSConst.CMP_FNT_REVERSE;
                        } else if (underline) {
                            ESCPOSConst.CMP_FNT_UNDERLINE
                        } else if (bold) {
                            ESCPOSConst.CMP_FNT_BOLD
                        } else {
                            when (font.toString()) {
                                "FONT_A" -> ESCPOSConst.CMP_FNT_DEFAULT
                                "FONT_B" -> ESCPOSConst.CMP_FNT_FONTB
                                "FONT_C" -> ESCPOSConst.CMP_FNT_FONTC
                                "FONT_D" -> ESCPOSConst.CMP_FNT_STRIKEOUT
                                "FONT_E" -> ESCPOSConst.CMP_FNT_ITALIC
                                else -> ESCPOSConst.CMP_FNT_DEFAULT
                            }
                        }

                        height = when (height) {
                            0 -> ESCPOSConst.CMP_TXT_1HEIGHT
                            1 -> ESCPOSConst.CMP_TXT_2HEIGHT
                            2 -> ESCPOSConst.CMP_TXT_3HEIGHT
                            3 -> ESCPOSConst.CMP_TXT_4HEIGHT
                            4 -> ESCPOSConst.CMP_TXT_5HEIGHT
                            5 -> ESCPOSConst.CMP_TXT_6HEIGHT
                            6 -> ESCPOSConst.CMP_TXT_7HEIGHT
                            7 -> ESCPOSConst.CMP_TXT_8HEIGHT
                            else -> ESCPOSConst.CMP_TXT_1HEIGHT
                        }
                        width = when (width) {
                            0 -> ESCPOSConst.CMP_TXT_1WIDTH
                            1 -> ESCPOSConst.CMP_TXT_2WIDTH
                            2 -> ESCPOSConst.CMP_TXT_3WIDTH
                            3 -> ESCPOSConst.CMP_TXT_4WIDTH
                            4 -> ESCPOSConst.CMP_TXT_5WIDTH
                            5 -> ESCPOSConst.CMP_TXT_6WIDTH
                            6 -> ESCPOSConst.CMP_TXT_7WIDTH
                            7 -> ESCPOSConst.CMP_TXT_8WIDTH
                            else -> ESCPOSConst.CMP_TXT_1WIDTH
                        }



                        result = posPtr.printText(
                            text.toString(),
                            align,
                            fontType,
                            width or height,
                        );

                        /* [YET TO IMPLEMENT] */
//                    result = posPtr.printTextLocalFont(
//                        text.toString(),
//                        textAlign,
//                        Typeface.SERIF,
//                        ESCPOSConst.CMP_FNT_BOLD,
//                        fontType,
//                        height,
//                        width,
//                    );
                        /* [YET TO IMPLEMENT] */
                    }

                    "addCut" -> {
                        var cutType = commandValue["cutType"] as String
                        result = when (cutType) {
                            "CUT_FEED" -> posPtr.cutPaper(ESCPOSConst.CMP_CUT_PARTIAL_PREFEED)
                            "CUT_NO_FEED" -> posPtr!!.cutPaper(ESCPOSConst.CMP_CUT_FULL)
                            "CUT_RESERVE" -> posPtr.cutPaper(ESCPOSConst.CMP_CUT_PARTIAL)
                            else -> posPtr!!.cutPaper(ESCPOSConst.CMP_CUT_PARTIAL_PREFEED)
                        }
                    }

                    "addFeedLine" -> {
                        var lines = (commandValue["lines"] as? Int) ?: 1
                        val newLines = "\n".repeat(lines)
                        result = posPtr.printText(
                            newLines,
                            align,
                            ESCPOSConst.CMP_FNT_DEFAULT,
                            ESCPOSConst.CMP_TXT_1HEIGHT or ESCPOSConst.CMP_TXT_1WIDTH,
                        );
                    }

                    "printRawData" -> {
                        result = posPtr.printData(commandValue as ByteArray)
                    }

                    "addImage" -> {

                        var byteArray: ByteArray = commandValue["bitmap"] as ByteArray
                        val bitmap: Bitmap? =
                            BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)

                        var md = commandValue["mode"];
                        var mode = when (md.toString()) {
                            "MODE_MONO" -> ESCPOSConst.CMP_BM_MODE_CMD_MONO
                            "MODE_GRAY16" -> ESCPOSConst.CMP_BM_MODE_CMD_GRAY16
                            else -> ESCPOSConst.CMP_BM_MODE_CMD_BITIMAGE
                        }
                        var ht = commandValue["halftone"];
                        if (ht != null) {
                            mode = when (ht.toString()) {
                                "HALFTONE_DITHER" -> ESCPOSConst.CMP_BM_MODE_HT_DITHER
                                "HALFTONE_THRESHOLD" -> ESCPOSConst.CMP_BM_MODE_HT_THRESHOLD
                                else -> ESCPOSConst.CMP_BM_MODE_HT_DITHER
                            }
                        }
                        result = posPtr.printBitmap(
                            bitmap,
                            ESCPOSConst.CMP_BM_ASIS,
                            ESCPOSConst.CMP_ALIGNMENT_CENTER,
                            mode,
                        );
                    }

                    "printQRCode" -> {
                        var data: String? = commandValue["data"] as? String
                            ?: throw RuntimeException("COMMAND ID :$commandId | error: QR DATA IS NULL $commandValue ")

                        var size = commandValue["size"] as? Int ?: 3

                        var ecLevel = when (commandValue["errorCorrectionLevel"]) {
                            "LOW" -> ESCPOSConst.CMP_QRCODE_EC_LEVEL_L
                            "MEDIUM" -> ESCPOSConst.CMP_QRCODE_EC_LEVEL_M
                            "QUARTER" -> ESCPOSConst.CMP_QRCODE_EC_LEVEL_Q
                            "HIGH" -> ESCPOSConst.CMP_QRCODE_EC_LEVEL_H
                            else -> ESCPOSConst.CMP_QRCODE_EC_LEVEL_L
                        }

                        posPtr.printQRCode(data, size, ecLevel, align);
                    }

                }
                if (ESCPOSConst.CMP_SUCCESS != result) {
                    throw RuntimeException("ERROR CODE: $result | COMMAND ID :$commandId")
                }
            }

        } catch (e: Exception) {
            Log.e(
                logTag + "CITIZEN PRINTER ERROR ${posPtr.modelName}",
                e.message ?: "error:${e.toString()}",
            );
        }


    }

}