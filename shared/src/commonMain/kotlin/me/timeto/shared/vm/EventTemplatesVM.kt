package me.timeto.shared.vm

import kotlinx.coroutines.flow.*
import me.timeto.shared.*
import me.timeto.shared.db.EventTemplateDB

class EventTemplatesVM : __VM<EventTemplatesVM.State>() {

    data class TemplateUI(
        val templateDB: EventTemplateDB,
        val text: String,
    ) {
        val timeForEventForm: Int = UnixTime().localDayStartTime() + templateDB.daytime
    }

    data class State(
        val templatesUI: List<TemplateUI>
    ) {
        val newTemplateText = "New Template"
    }

    override val state = MutableStateFlow(
        State(
            templatesUI = DI.eventTemplatesSorted.toTemplatesUI(),
        )
    )

    override fun onAppear() {
        val scope = scopeVM()
        EventTemplateDB.selectAscSortedFlow().onEachExIn(scope) { templatesDB ->
            state.update {
                it.copy(templatesUI = templatesDB.toTemplatesUI())
            }
        }
    }
}

private fun List<EventTemplateDB>.toTemplatesUI() = this
    .reversed()
    .map { templateDB ->
        EventTemplatesVM.TemplateUI(
            templateDB = templateDB,
            text = templateDB.text.textFeatures().textNoFeatures.let {
                if (it.length <= 17) it else it.substring(0..14) + ".."
            },
        )
    }