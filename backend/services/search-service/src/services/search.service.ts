import { Repository } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import { AppDataSource } from '@config/database';
import { SearchLog } from '@models/Search';

export class SearchService {
  private repository: Repository<SearchLog>;

  constructor() {
    this.repository = AppDataSource.getRepository(SearchLog);
  }

  async logSearch(userId: string | null, keyword: string, resultCount: number, filters?: any): Promise<SearchLog> {
    const log = this.repository.create({
      searchLogId: uuidv4(),
      userId,
      keyword,
      resultCount,
      filters: filters || {},
    });
    return await this.repository.save(log);
  }

  async getPopularKeywords(limit: number = 10): Promise<any[]> {
    const results = await this.repository
      .createQueryBuilder('log')
      .select('log.keyword', 'keyword')
      .addSelect('COUNT(*)', 'count')
      .groupBy('log.keyword')
      .orderBy('count', 'DESC')
      .limit(limit)
      .getRawMany();

    return results;
  }

  async getUserSearchHistory(userId: string, limit: number = 20): Promise<SearchLog[]> {
    return await this.repository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  async searchProducts(keyword: string, filters?: any): Promise<any> {
    // 실제 구현에서는 ElasticSearch나 다른 검색 엔진을 사용
    // 여기서는 간단한 시뮬레이션
    return {
      keyword,
      filters: filters || {},
      results: [],
      total: 0,
    };
  }
}
