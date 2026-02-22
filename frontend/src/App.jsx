import React, { useState, useEffect } from 'react';

const API_URL = '/api';

function App() {
    const [tasks, setTasks] = useState([]);
    const [inputValue, setInputValue] = useState('');

    const fetchTasks = async () => {
        try {
            const response = await fetch(`${API_URL}/tasks`);
            if (!response.ok) throw new Error('Failed to fetch tasks');
            const data = await response.json();
            setTasks(data);
        } catch (error) {
            console.error('Error fetching tasks:', error);
        }
    };

    useEffect(() => {
        fetchTasks();
    }, []);

    const addTask = async () => {
        const title = inputValue.trim();
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
                setInputValue('');
                fetchTasks();
            }
        } catch (error) {
            console.error('Error adding task:', error);
        }
    };

    const renderColumn = (status, title, bgClass, headerClass, badgeBgClass) => {
        const columnTasks = tasks.filter((t) => t.status === status);
        return (
            <div className={`${bgClass} p-4 rounded-xl shadow-md border ${bgClass.replace('bg-', 'border-').replace('50', '200')}`}>
                <h2 className={`text-xl font-bold mb-4 ${headerClass} border-b ${headerClass.replace('text-', 'border-').replace('800', '200')} pb-2 flex justify-between items-center`}>
                    {title}
                    <span className={`${badgeBgClass} ${headerClass} text-sm py-1 px-3 rounded-full`}>{columnTasks.length}</span>
                </h2>
                <div className="space-y-3 min-h-[200px]">
                    {columnTasks.map((task, idx) => (
                        <div key={idx} className="bg-white p-4 rounded-lg shadow-sm border border-gray-100 task-card flex justify-between items-center transform transition duration-300 hover:scale-[1.02] hover:-translate-y-1">
                            <span className="font-medium text-gray-800">{task.title}</span>
                            <div className="text-xs text-gray-400">#{task.id}</div>
                        </div>
                    ))}
                </div>
            </div>
        );
    };

    return (
        <div className="container mx-auto p-4 animate-fade-in-up">
            <header className="mb-8 text-center pt-8">
                <h1 className="text-4xl font-extrabold text-blue-600 mb-2 drop-shadow-sm">My TaskFlow</h1>
                <p className="text-gray-600 font-medium">A sleek Kanban board using React</p>
            </header>

            <div className="mb-8 max-w-md mx-auto">
                <div className="flex gap-2 shadow-lg rounded-lg overflow-hidden border border-gray-200 bg-white">
                    <input
                        type="text"
                        value={inputValue}
                        onChange={(e) => setInputValue(e.target.value)}
                        onKeyDown={(e) => e.key === 'Enter' && addTask()}
                        placeholder="What needs to be done?"
                        className="flex-1 p-4 focus:outline-none"
                    />
                    <button
                        onClick={addTask}
                        className="bg-blue-600 text-white px-6 py-4 hover:bg-blue-700 transition font-bold tracking-wide"
                    >
                        Add Task
                    </button>
                </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {renderColumn('todo', 'To Do', 'bg-gray-50', 'text-gray-700', 'bg-gray-200')}
                {renderColumn('inprogress', 'In Progress', 'bg-blue-50', 'text-blue-800', 'bg-blue-200')}
                {renderColumn('done', 'Done', 'bg-green-50', 'text-green-800', 'bg-green-200')}
            </div>
        </div>
    );
}

export default App;
