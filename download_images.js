const fs = require('fs');
const path = require('path');
const https = require('https');

// 基础URL配置
const BASE_URL = 'https://mp-1af92f1c-94c6-441d-86c3-3a0c66fb0618.cdn.bspapp.com/tiku';

// Question.bundle 目录路径
const QUESTION_BUNDLE_PATH = path.join(__dirname, 'RuanKao/Question.bundle');

// 图片保存目录
const OUTPUT_DIR = path.join(__dirname, 'downloaded_images');

// 统计信息
const stats = {
  totalJsonFiles: 0,
  totalImages: 0,
  downloadedImages: 0,
  failedImages: 0,
  skippedImages: 0
};

/**
 * 确保目录存在，如果不存在则创建
 */
function ensureDirectoryExists(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

/**
 * 下载图片
 */
function downloadImage(url, outputPath) {
  return new Promise((resolve, reject) => {
    // 检查文件是否已存在
    if (fs.existsSync(outputPath)) {
      console.log(`跳过已存在的文件: ${path.basename(outputPath)}`);
      stats.skippedImages++;
      resolve();
      return;
    }

    https.get(url, (response) => {
      if (response.statusCode === 200) {
        const fileStream = fs.createWriteStream(outputPath);
        response.pipe(fileStream);
        
        fileStream.on('finish', () => {
          fileStream.close();
          stats.downloadedImages++;
          console.log(`✓ 下载成功: ${path.basename(outputPath)}`);
          resolve();
        });
        
        fileStream.on('error', (err) => {
          fs.unlink(outputPath, () => {}); // 删除不完整的文件
          stats.failedImages++;
          console.error(`✗ 写入失败: ${path.basename(outputPath)} - ${err.message}`);
          reject(err);
        });
      } else {
        stats.failedImages++;
        console.error(`✗ 下载失败 (${response.statusCode}): ${url}`);
        reject(new Error(`HTTP ${response.statusCode}`));
      }
    }).on('error', (err) => {
      stats.failedImages++;
      console.error(`✗ 请求失败: ${url} - ${err.message}`);
      reject(err);
    });
  });
}

/**
 * 递归查找所有JSON文件
 */
function findJsonFiles(dir, fileList = []) {
  const files = fs.readdirSync(dir);
  
  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    
    if (stat.isDirectory()) {
      findJsonFiles(filePath, fileList);
    } else if (path.extname(file) === '.json') {
      fileList.push(filePath);
    }
  });
  
  return fileList;
}

/**
 * 从JSON文件中提取图片信息
 */
function extractImagesFromJson(jsonPath) {
  const images = [];
  
  try {
    const content = fs.readFileSync(jsonPath, 'utf8');
    const data = JSON.parse(content);
    
    // 获取courseId（从JSON数据中提取）
    let courseId = null;
    let questions = [];
    
    // 处理不同的JSON结构
    if (data.success && data.data && data.data.data) {
      questions = data.data.data;
    } else if (Array.isArray(data)) {
      questions = data;
    } else if (data.data && Array.isArray(data.data)) {
      questions = data.data;
    }
    
    // 遍历所有题目
    questions.forEach((question, index) => {
      if (!courseId && question.course_id) {
        courseId = question.course_id;
      }
      
      // 提取tigan_pic
      if (question.tigan_pic && question.tigan_pic.trim() !== '') {
        images.push({
          type: 'tigan_pic',
          filename: question.tigan_pic,
          courseId: question.course_id || courseId,
          questionId: question.id || `question_${index}`,
          jsonPath: jsonPath
        });
      }
      
      // 提取explanation_pic
      if (question.explanation_pic && question.explanation_pic.trim() !== '') {
        images.push({
          type: 'explanation_pic',
          filename: question.explanation_pic,
          courseId: question.course_id || courseId,
          questionId: question.id || `question_${index}`,
          jsonPath: jsonPath
        });
      }
    });
  } catch (error) {
    console.error(`解析JSON文件失败: ${jsonPath} - ${error.message}`);
  }
  
  return images;
}

/**
 * 延迟函数
 */
function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * 主函数
 */
async function main() {
  console.log('='.repeat(60));
  console.log('开始下载Question.bundle中的图片');
  console.log('='.repeat(60));
  console.log();
  
  // 确保输出目录存在
  ensureDirectoryExists(OUTPUT_DIR);
  
  // 查找所有JSON文件
  console.log('正在扫描JSON文件...');
  const jsonFiles = findJsonFiles(QUESTION_BUNDLE_PATH);
  stats.totalJsonFiles = jsonFiles.length;
  console.log(`找到 ${stats.totalJsonFiles} 个JSON文件\n`);
  
  // 收集所有图片信息
  console.log('正在提取图片信息...');
  const allImages = [];
  jsonFiles.forEach((jsonPath, index) => {
    const images = extractImagesFromJson(jsonPath);
    allImages.push(...images);
    if ((index + 1) % 50 === 0) {
      console.log(`已处理 ${index + 1}/${stats.totalJsonFiles} 个文件`);
    }
  });
  stats.totalImages = allImages.length;
  console.log(`共找到 ${stats.totalImages} 张图片\n`);
  
  // 按courseId分组图片
  const imagesByFolder = {};
  allImages.forEach(img => {
    const folderKey = `course_${img.courseId || 'unknown'}`;
    if (!imagesByFolder[folderKey]) {
      imagesByFolder[folderKey] = [];
    }
    imagesByFolder[folderKey].push(img);
  });
  
  // 下载图片
  console.log('开始下载图片...\n');
  let currentImage = 0;
  
  for (const [folder, images] of Object.entries(imagesByFolder)) {
    const folderPath = path.join(OUTPUT_DIR, folder);
    ensureDirectoryExists(folderPath);
    
    console.log(`\n处理课程: ${folder} (${images.length} 张图片)`);
    console.log('-'.repeat(60));
    
    for (const img of images) {
      currentImage++;
      const url = `${BASE_URL}/${img.courseId}/${img.filename}`;
      const outputPath = path.join(folderPath, img.filename);
      
      console.log(`[${currentImage}/${stats.totalImages}] ${img.type}: ${img.filename}`);
      
      try {
        await downloadImage(url, outputPath);
        // 添加小延迟避免请求过快
        await delay(100);
      } catch (error) {
        // 错误已在downloadImage中处理
      }
    }
  }
  
  // 打印统计信息
  console.log('\n' + '='.repeat(60));
  console.log('下载完成！统计信息:');
  console.log('='.repeat(60));
  console.log(`JSON文件总数: ${stats.totalJsonFiles}`);
  console.log(`图片总数: ${stats.totalImages}`);
  console.log(`成功下载: ${stats.downloadedImages}`);
  console.log(`跳过(已存在): ${stats.skippedImages}`);
  console.log(`下载失败: ${stats.failedImages}`);
  console.log(`\n图片保存位置: ${OUTPUT_DIR}`);
  console.log('='.repeat(60));
}

// 运行主函数
main().catch(error => {
  console.error('程序执行出错:', error);
  process.exit(1);
});
