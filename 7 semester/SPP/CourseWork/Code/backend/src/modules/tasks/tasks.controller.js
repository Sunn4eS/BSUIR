/**
 * modules/tasks/tasks.controller.js
 */
const tasksService = require('./tasks.service');

class TasksController {
  async createTask(req, res, next) {
    try {
      const task = await tasksService.createTask(req.params.courseId, req.user.id, req.body);
      res.status(201).json({ task });
    } catch (e) { next(e); }
  }

  async updateTask(req, res, next) {
    try {
      const task = await tasksService.updateTask(req.params.id, req.user.id, req.body);
      res.json({ task });
    } catch (e) { next(e); }
  }

  async deleteTask(req, res, next) {
    try {
      const result = await tasksService.deleteTask(req.params.id, req.user.id);
      res.json(result);
    } catch (e) { next(e); }
  }

  async getTemplates(req, res, next) {
    try {
      const templates = await tasksService.getTemplates(req.user.id);
      res.json({ templates });
    } catch (e) { next(e); }
  }

  async submitResult(req, res, next) {
    try {
      const result = await tasksService.submitTaskResult(
        req.user.id, req.params.taskId, req.body
      );
      res.json({ result });
    } catch (e) { next(e); }
  }

  async getResults(req, res, next) {
    try {
      const results = await tasksService.getStudentResults(
        req.user.id, req.params.courseId
      );
      res.json({ results });
    } catch (e) { next(e); }
  }
}

module.exports = new TasksController();
