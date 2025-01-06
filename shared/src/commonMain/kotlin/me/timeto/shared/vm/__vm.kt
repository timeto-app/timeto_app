package me.timeto.shared.vm

import kotlinx.coroutines.*
import kotlinx.coroutines.flow.StateFlow
import me.timeto.shared.defaultScope

abstract class __Vm<T> {

    abstract val state: StateFlow<T>

    ///

    private val scopes = mutableListOf<CoroutineScope>()

    protected fun scopeVm() = defaultScope().apply { scopes.add(this) }

    ///

    suspend fun onUi(block: () -> Unit) {
        withContext(Dispatchers.Main) { block() }
    }

    open fun onAppear() {}

    fun onDisappear() {
        scopes.forEach { it.cancel() }
        scopes.clear()
    }
}
