const API_URL = '/api'; // Use relative path for Ingress/Proxy routing

async function fetchTasks() {
    try {
        const response = await fetch(`${API_URL}/tasks`);
        if (!response.ok) throw new Error('Failed to fetch tasks');
        const tasks = await response.json();
        renderTasks(tasks);
    } catch (error) {
        console.error('Error:', error);
    }
}

function renderTasks(tasks) {
    const todoList = document.getElementById('todo-list');
    const inProgressList = document.getElementById('inprogress-list');
    const doneList = document.getElementById('done-list');

    // Clear lists
    todoList.innerHTML = '';
    inProgressList.innerHTML = '';
    doneList.innerHTML = '';

    let todoCount = 0;
    let inProgressCount = 0;
    let doneCount = 0;

    tasks.forEach(task => {
        const card = createTaskCard(task);
        if (task.status === 'todo') {
            todoList.appendChild(card);
            todoCount++;
        } else if (task.status === 'inprogress') {
            inProgressList.appendChild(card);
            inProgressCount++;
        } else if (task.status === 'done') {
            doneList.appendChild(card);
            doneCount++;
        }
    });

    // Update counters
    document.getElementById('todo-count').innerText = todoCount;
    document.getElementById('inprogress-count').innerText = inProgressCount;
    document.getElementById('done-count').innerText = doneCount;
}

function createTaskCard(task) {
    const div = document.createElement('div');
    div.className = 'bg-white p-4 rounded-lg shadow-sm border border-gray-100 task-card flex justify-between items-center';
    div.innerHTML = `
        <span class="font-medium text-gray-800">${task.title}</span>
        <div class="text-xs text-gray-400">#${task.id}</div>
    `;
    return div;
}

async function addTask() {
    const input = document.getElementById('taskInput');
    const title = input.value.trim();
    if (!title) return;

    try {
        const response = await fetch(`${API_URL}/tasks`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ title, status: 'todo' }),
        });

        if (response.ok) {
            input.value = '';
            fetchTasks(); // Refresh list
        }
    } catch (error) {
        console.error('Error adding task:', error);
    }
}

// Initial load
fetchTasks();
