 USE task_management;
 
 INSERT INTO tasks(title, description, status)
 VALUES
 ('tarefa 1', 'Nueva descripcion', 'pending'),
 ('tarefa 2', 'Nueva descripcion', 'pending'),
 ('tarefa 3', 'Nueva descripcion', 'in progress'),
 ('tarefa 4', 'Nueva descripcion', 'completed'),
 ('tarefa 5', 'Nueva descripcion', 'pending');
 
 DELIMITER //
CREATE FUNCTION count_tasks_by_status(status_value ENUM('pending', 'completed', 'in progress'))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE task_count INT;
    SELECT COUNT(*) INTO task_count FROM tasks WHERE status = status_value;
    RETURN task_count;
END //
DELIMITER ;

select count_tasks_by_status('pending') as pending_tasks;

select count_tasks_by_status('completed') as completed_tasks;

select count_tasks_by_status('in progress') as pending_tasks;

 
 DELIMITER //
CREATE TRIGGER update_task_timestamp
BEFORE UPDATE ON tasks
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END //
DELIMITER ;

Select * from tasks;

select * from tasks where status  = 'pending';

select (select count(*) from tasks) as total_tasks;
