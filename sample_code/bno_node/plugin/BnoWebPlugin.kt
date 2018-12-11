package com.leia.bno.plugin

import com.leia.bno.api.BnoApi
import net.corda.webserver.services.WebServerPluginRegistry
import java.util.function.Function

class BnoWebPlugin : WebServerPluginRegistry {
    override val webApis = listOf(Function(::BnoApi))
}