"""Todo item component for displaying a single todo."""

def:pub TodoItem(todo: dict, onToggle: any, onDelete: any) -> any {
    titleClass = "todo-title-completed" if todo.completed else "todo-title";

    return
        <div key={todo.id} className="todo-item">
            <input
                type="checkbox"
                checked={todo.completed}
                onChange={lambda -> None { onToggle(todo.id);}}
                className="todo-checkbox"
            />
            <span className={titleClass}>
                {todo.title}
            </span>
            <button
                onClick={lambda -> None { onDelete(todo.id);}}
                className="btn-delete"
            >
                x
            </button>
        </div>;
}
