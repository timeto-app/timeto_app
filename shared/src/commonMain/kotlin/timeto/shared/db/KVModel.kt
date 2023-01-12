package timeto.shared.db

import com.squareup.sqldelight.runtime.coroutines.asFlow
import com.squareup.sqldelight.runtime.coroutines.mapToList
import com.squareup.sqldelight.runtime.coroutines.mapToOneOrNull
import dbsq.KVSQ
import kotlinx.coroutines.flow.map

data class KVModel(
    val key: String,
    val value: String,
) {

    companion object {

        const val DAY_START_OFFSET_SECONDS_DEFAULT = 0

        suspend fun getAll() = dbIO {
            db.kVQueries.getAll().executeAsList().map { it.toModel() }
        }

        fun getAllFlow() = db.kVQueries.getAll().asFlow()
            .mapToList().map { list -> list.map { it.toModel() } }

        fun getByKeyOrNullFlow(key: KEY) = db.kVQueries.getByKey(key.name).asFlow()
            .mapToOneOrNull().map { it?.toModel() }

        suspend fun upsert(key: KEY, value: String): Unit = addRaw(k = key.name, v = value)

        fun addRaw(k: String, v: String) {
            db.kVQueries.upsert(key = k, value_ = v)
        }

        fun truncate() {
            db.kVQueries.truncate()
        }

        private fun KVSQ.toModel() = KVModel(
            key = key, value = value_
        )
    }

    enum class KEY {
        EVENTS_HISTORY,
        IS_SHOW_README_ON_MAIN,
        DAY_START_OFFSET_SECONDS,
    }
}
