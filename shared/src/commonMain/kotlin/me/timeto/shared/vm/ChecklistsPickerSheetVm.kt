package me.timeto.shared.vm

import kotlinx.coroutines.flow.*
import me.timeto.shared.Cache
import me.timeto.shared.db.ChecklistDb
import me.timeto.shared.onEachExIn

class ChecklistsPickerSheetVm(
    selectedChecklistsDb: List<ChecklistDb>,
) : __Vm<ChecklistsPickerSheetVm.State>() {

    data class State(
        val checklistsDb: List<ChecklistDb>,
        val selectedIds: Set<Int>,
    ) {

        val title = "Checklists"
        val doneText = "Done"
        val newChecklistText = "New Checklist"

        val checklistsDbSorted: List<ChecklistDb> =
            checklistsDb.sortedByDescending { it.id in selectedIds }
    }

    override val state = MutableStateFlow(
        State(
            checklistsDb = Cache.checklistsDb,
            selectedIds = selectedChecklistsDb.map { it.id }.toSet(),
        )
    )

    init {
        val scopeVm = scopeVm()
        ChecklistDb.selectAscFlow().onEachExIn(scopeVm) { checklistsDb ->
            state.update { it.copy(checklistsDb = checklistsDb) }
        }
    }

    ///

    fun selectById(id: Int) {
        val newSelectedIds = state.value.selectedIds.toMutableSet()
        newSelectedIds.add(id)
        state.update { it.copy(selectedIds = newSelectedIds) }
    }

    fun toggleChecklist(checklistDb: ChecklistDb) {
        val newSelectedIds = state.value.selectedIds.toMutableSet()
        val checklistId: Int = checklistDb.id
        if (checklistId in newSelectedIds)
            newSelectedIds.remove(checklistId)
        else
            newSelectedIds.add(checklistId)
        state.update {
            it.copy(selectedIds = newSelectedIds)
        }
    }

    fun setSelectedIds(ids: Set<Int>) {
        state.update { it.copy(selectedIds = ids) }
    }

    fun getSelectedChecklistsDb(): List<ChecklistDb> =
        state.value.checklistsDb.filter { it.id in state.value.selectedIds }
}
