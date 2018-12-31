import net.corda.webserver.services.WebServerPluginRegistry
import java.util.function.Function

class BnoWebPlugin : WebServerPluginRegistry {
    override val webApis = listOf(Function(::BnoApi))
}