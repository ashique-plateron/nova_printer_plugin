package com.nova.priter.plugin.nova_printer_plugin

import JSONConvertable


data class PrinterResult(
    var type: String,
    var success: Boolean,
    var message: String? = null,
    var content: Any? = null
) : JSONConvertable